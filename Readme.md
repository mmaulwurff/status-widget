# Status Widget

Status Widget is an add-on for GZDoom. It displays changes of health, armor,
ammo and inventory items.

This mod is a part of [m8f's toolbox](https://mmaulwurff.github.io/pages/toolbox).

## Features

- minimalistic UI
- extendable - it's possible to add more message types.
- customizable

## API

Status Widget is extendable - you can track any kind of thing. To do this,
create a class that inherits sw_Tracker and override its methods:

- `initialize()` is used to set up your tracker.

- `sw_Messages getStatus(Dictionary savedStatus)` is used to create
  messages. `savedStatus` contains last reported status: counts of things player
  had before this moment. Trackers read and write to `savedStatus`. See
  `sw_InventoryTracker` for an example.

Messages with the same name will be squished together if they are next to each
other.

## Info

Author: m8f (mmaulwurff@gmail.com)

License: GPLv3 (see copying.txt).

[Source](https://github.com/mmaulwurff/status-widget/)
