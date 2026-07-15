#!/usr/bin/env python3
"""Print the worksheet tab names of an .xls/.xlsx file, in tab order, one per line.

Usage: sheetnames.py FILE

Zero dependencies: parses .xlsx (zip+XML) and legacy .xls (OLE2/BIFF) directly.
"""
import struct
import sys
import xml.etree.ElementTree as ET
import zipfile


def xlsx_names(path):
    """Sheet names in tab order from an Office Open XML (.xlsx/.xlsm) file."""
    with zipfile.ZipFile(path) as z:
        root = ET.fromstring(z.read("xl/workbook.xml"))
    # <sheet> elements under <sheets> are in tab order. Strip namespaces.
    names = []
    for el in root.iter():
        if el.tag.rsplit("}", 1)[-1] == "sheet":
            name = el.get("name")
            if name is not None:
                names.append(name)
    return names


def _read_ole(path):
    """Return a dict mapping stream name -> bytes for an OLE2 compound file."""
    data = open(path, "rb").read()
    if data[:8] != b"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1":
        raise ValueError("not an OLE2 compound file")

    sector_size = 1 << struct.unpack_from("<H", data, 30)[0]
    mini_size = 1 << struct.unpack_from("<H", data, 32)[0]
    num_fat = struct.unpack_from("<I", data, 44)[0]
    dir_start = struct.unpack_from("<I", data, 48)[0]
    mini_cutoff = struct.unpack_from("<I", data, 56)[0]
    minifat_start = struct.unpack_from("<I", data, 60)[0]
    difat_start = struct.unpack_from("<I", data, 68)[0]
    num_difat = struct.unpack_from("<I", data, 72)[0]

    def sector(n):
        off = 512 + n * sector_size
        return data[off:off + sector_size]

    # Build the DIFAT (list of FAT sector numbers): first 109 from the header,
    # then follow the DIFAT chain if present.
    difat = list(struct.unpack_from("<109I", data, 76))
    sec = difat_start
    for _ in range(num_difat):
        if sec >= 0xFFFFFFFE:
            break
        chunk = sector(sec)
        ints = struct.unpack("<%dI" % (sector_size // 4), chunk)
        difat.extend(ints[:-1])
        sec = ints[-1]
    difat = [s for s in difat[:num_fat] if s < 0xFFFFFFFE]

    # Read the FAT.
    fat = []
    for s in difat:
        fat.extend(struct.unpack("<%dI" % (sector_size // 4), sector(s)))

    def chain(start):
        out, s, seen = [], start, set()
        while s < 0xFFFFFFFE and s not in seen:
            seen.add(s)
            out.append(s)
            s = fat[s] if s < len(fat) else 0xFFFFFFFE
        return out

    def read_chain(start):
        return b"".join(sector(s) for s in chain(start))

    # Directory entries (128 bytes each).
    dir_data = read_chain(dir_start)
    entries = []
    for i in range(0, len(dir_data), 128):
        e = dir_data[i:i + 128]
        if len(e) < 128:
            break
        nlen = struct.unpack_from("<H", e, 64)[0]
        name = e[:max(nlen - 2, 0)].decode("utf-16-le", "replace")
        etype = e[66]
        start = struct.unpack_from("<I", e, 116)[0]
        size = struct.unpack_from("<I", e, 120)[0]
        entries.append((name, etype, start, size))

    # Root entry (type 5) holds the mini stream in the regular FAT.
    root = next((e for e in entries if e[1] == 5), None)
    mini_stream = read_chain(root[2]) if root else b""

    # Mini FAT.
    minifat = []
    for s in chain(minifat_start) if minifat_start < 0xFFFFFFFE else []:
        minifat.extend(struct.unpack("<%dI" % (sector_size // 4), sector(s)))

    def read_mini(start, size):
        out, s, seen = [], start, set()
        while s < 0xFFFFFFFE and s not in seen:
            seen.add(s)
            off = s * mini_size
            out.append(mini_stream[off:off + mini_size])
            s = minifat[s] if s < len(minifat) else 0xFFFFFFFE
        return b"".join(out)[:size]

    streams = {}
    for name, etype, start, size in entries:
        if etype != 2:  # only stream objects
            continue
        if size < mini_cutoff:
            streams[name] = read_mini(start, size)
        else:
            streams[name] = read_chain(start)[:size]
    return streams


def xls_names(path):
    """Sheet names in tab order from a legacy BIFF .xls file."""
    streams = _read_ole(path)
    wb = streams.get("Workbook") or streams.get("Book")
    if wb is None:
        raise ValueError("no Workbook/Book stream found")

    names = []
    i = 0
    n = len(wb)
    while i + 4 <= n:
        rectype, length = struct.unpack_from("<HH", wb, i)
        i += 4
        body = wb[i:i + length]
        i += length
        if rectype == 0x0085:  # BOUNDSHEET
            # 4 bytes BOF position, 1 byte visibility, 1 byte type, then name.
            cch = body[6]
            grbit = body[7]
            raw = body[8:]
            if grbit & 0x01:  # UTF-16LE
                names.append(raw[:cch * 2].decode("utf-16-le", "replace"))
            else:  # compressed / Latin-1
                names.append(raw[:cch].decode("latin-1", "replace"))
        elif rectype == 0x000A:  # EOF of the globals substream
            break
    return names


def main(argv):
    if len(argv) != 2:
        sys.stderr.write("usage: %s FILE.xls|FILE.xlsx\n" % argv[0])
        return 2
    path = argv[1]
    try:
        if zipfile.is_zipfile(path):
            names = xlsx_names(path)
        else:
            names = xls_names(path)
    except Exception as e:
        sys.stderr.write("error: %s\n" % e)
        return 1
    for name in names:
        print(name)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
