# What this configuration lets you do

## 1. Reusable feature bundles
Define a feature once — SSH hardening, a browser, a shell setup, a desktop
environment — and mix it into any machine or person. Bundles can include
other bundles, nested arbitrarily deep, so a big feature (e.g. a full desktop
setup) is really several smaller ones composed together.

## 2. Custom fields on machines and people
Attach structured, typed metadata to a machine or a person beyond the
built-ins — disk layout, target OS version, email address, etc. Typos or
undeclared fields fail at build time instead of silently doing nothing.

## 3. Context-aware features
A single feature definition can emit different config depending on *where*
it's attached — the same feature written once can behave differently applied
to a machine versus applied to a person, without branching logic.

## 4. Cross-entity delivery
- A machine can push config to every person who has an account on it, or to
  one named person only.
- A person can push config to every machine they have an account on, or to
  one named machine only.

This is how, e.g., a per-machine setting reaches every user's environment on
that machine without each user redeclaring it.

## 5. Fleet-wide broadcast/collect
A machine can publish a fact about itself — its SSH endpoint, a port it
needs open, etc. — into a shared channel, and every other machine
automatically collects everything published there. Adding a new machine
doesn't require updating every other machine's config by hand; membership in
the fleet is enough. (Your SSH client config across hosts already works this
way.)

## 6. Structural queries ("does this already have X?")
A feature can ask "is feature X already applied anywhere in this machine's
(or person's) setup?" and adjust its own behavior based on the answer —
useful for feature bundles that need to cooperate or avoid duplicating work
done by another bundle already in the tree.

## 7. Forced exclusivity / substitution
One feature can be marked as authoritatively excluding or replacing another
across part of the tree — e.g. guaranteeing two mutually incompatible disk
layout features can never both apply to the same machine, even if something
downstream tries to include both.

## 8. Write once, target multiple OS families
A single config line can apply to both Linux and Mac machines at once
instead of duplicating it per OS. Basic user-account definition (shell,
groups, home directory) has the same "write once" shortcut, independent of
which OS the account ends up on.

## 9. Turn a person into a home-environment user
Any person can opt into one or more personal-environment backends (their own
package set, dotfiles, session config) per machine they use. A person can be
opted into more than one backend at once if needed, and which backends are
active is controlled independently per person.
