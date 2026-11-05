---
name: sme-question
description: Draft a question or a confirmation note for a subject-matter expert (a product owner, analyst, or other non-engineer who owns the domain rules) that Josh will paste into a ticket thread, Slack, or email. Use when he says "write a question for <person>", "draft something to post back so <person> can confirm", "ask Product", "write the clarification for the SME", or when an open product decision blocks engineering work. Produces one paste-ready message in the expert's vocabulary that states current behavior, the proposed rule, and the single open choice, and records every correction in references/preferences.md.
---

# SME question

**Read `references/preferences.md` before drafting.** It records how Josh wants
these written, and it overrides anything below.

Josh is the engineer, not the domain expert. The message goes to someone who
knows the rules of the domain and does not read code. They should be able to
answer in one reply without asking what anything means.

## 1. Sort the open points before writing anything

List every open point, then split it:

- **Product decisions** go to the expert: what the user sees, which number is
  right, which rule applies in which case.
- **Engineering decisions** stay out of the message: how the code tells two
  cases apart, what happens to stored data, migrations, signatures, naming.
  Decide them, tell Josh what was decided, and let him override.

If nothing is left for the expert, say so and write no message.

## 2. Check every source you cite

- Quote a spec, ticket, or earlier ruling only after reading it in this
  session, and attribute each rule to where it actually came from. An
  engineering plan is not the spec.
- If the spec is silent on the case, say it is silent. Do not stretch a nearby
  rule to cover it.

## 3. Explain the mechanism before asking

The expert cannot pick an option until they know what the system does today and
why their case lands where it does. Before the question, say in two or three
sentences:

- what happens today, with one concrete number from their own report;
- why their case hits it (which path it takes, in their terms).

## 4. Write the message

- **Describe behavior, not code.** Say what price, value, or result each case
  produces. No function, class, field, or file names.
- **Use their vocabulary**, and only theirs. If a word would make them ask what
  it means, replace it.
- **Lay it out along their split**, the axis they would choose by (for example
  by cost model, by deal type, by user role).
- **Put one rule on each line**, so they can confirm or correct line by line.
- **Give an order when rules fall back** ("1. the buyer's value; 2. otherwise
  the measured one; 3. otherwise the seller's").
- **Pull the one open choice out under its own label** ("One thing to
  confirm"), stating what it does today and what is proposed.
- **Anchor in their own examples.** Name the cases and expected numbers from
  their report so they can check the rule against data they already know.
- **Say where scope stops**, naming the follow-up ticket that covers the rest.
- **Ask for line-by-line correction**: "Please confirm or correct any line."

Two shapes, depending on the stage:

- **Question** (rule not decided): current behavior, the gap, then lettered
  options. Recommend one to Josh in chat, not in the message.
- **Confirmation** (rule decided, about to build): the rule as it will behave,
  the one open choice, then the expected numbers.

## 5. Format for where it will be pasted

- **Linear and Slack renumber nested lists.** A sub-bullet under an option
  becomes its own numbered option. Keep option lists flat; put sub-cases in a
  sentence or a separate bolded line.
- Use bold lead-ins for the groups, not headings. Keep it to one screen.
- Give the message in a quote block or fenced block so Josh can copy it whole.

## 6. Reread it as the expert

Before handing it over:

- Every term is one they use.
- Every cited rule was read this session and is attributed correctly.
- Exactly one decision is asked for, or the options are mutually exclusive.
- Every number came from their report or from code you read.
- It answers what Josh asked. If he asked a yes/no question, answer yes or no
  first.

## 7. Record corrections

When Josh corrects a draft, add the lesson to `references/preferences.md` as a
one-line rule with a short reason, then redraft. Do not argue the old draft.

## Example

A confirmation note in the shape this skill produces (domain is illustrative):

> Here's how shipping charges will work once the fix is in. Please confirm or
> correct any line.
>
> **Any new rate card (flat, carrier, or saved custom card) replaces only the
> merchant's base rates.** Their own base rate lines are swapped for the card's.
>
> **On the Merchant pricing model**, everything the merchant adds on top of
> their base rates still applies:
> - Fuel surcharges and handling fees, wherever they are set.
> - Extra zone adjustments, such as Zone 4's +$1.25.
> - Oversize as a share of the standard rate, taken from the card's rate.
>
> If the merchant has no oversize lines, oversize is charged at the card's
> standard rate, until account-level defaults (TICKET-126) exist.
>
> **On the Buyer pricing model**, for each of standard, express and oversize:
> 1. The buyer's surcharge, if the model has one.
> 2. Otherwise the surcharge measured from invoices, if the account has them.
> 3. Otherwise the merchant's own lines.
>
> **One thing to confirm:** a buyer surcharge set as "$ fee + % of rate" takes
> its % from the merchant's setup, the same as on the merchant's own rates.
> Until now, new rate cards used 100% of the rate. Is taking the merchant's %
> right?
>
> **Your expected numbers:** cases 1 to 5 on the flat $70 card, and the Zone 4
> order (69.43), are the targets for the fix. We'll show them in the PR.
