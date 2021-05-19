# Status Widget

Status Widget is an add-on for GZDoom. It displays changes of health, armor,
ammo and inventory items.

![Screenshot](screenshots/armor-health.png)

This mod is a part of [m8f's toolbox](https://mmaulwurff.github.io/pages/toolbox).

## Features

- minimalistic UI;
- customizable;
- extendable - see API.

## API

Status Widget is extendable - you can track any kind of thing. To do this,
create a class that inherits sw_Tracker. See `zscript/status-widget/tracker.zs`
for API documentation and `sw_InventoryTracker` for an example.

## Acknowledgments

- Thanks to Ac!d for bug reports.

## Info

Author: m8f (mmaulwurff@gmail.com)

License: GPLv3 (see copying.txt).

[Source](https://github.com/mmaulwurff/status-widget/)
