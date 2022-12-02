# Input Selector

*This is a work in progress, and is very specific to my setup at this time.*

I wanted to add a drop-down selector to my menu bar in order to switch inputs on one or all of my displays. I found out that my displays support DDC commands, so this just wraps some command-line tools into a menu bar app.

## Prerequisites

* [xbar](https://github.com/matryer/xbar)
* [ddcctl](https://github.com/kfix/ddcctl)
* [edid-decode](https://git.linuxtv.org/edid-decode.git/about/)

## Installation

1. Clone this repository

		$ git clone git@github.com:cjohara/input-selector.git
		$ cd input-selector/

2. Copy input-selector.sh to xbar's plugin folder. NOTE: You can change how often the plugin detects your connected displays by changing the `1m` to a different interval. See [xbar's configure refresh time documentation](https://github.com/matryer/xbar-plugins/blob/main/CONTRIBUTING.md#configure-the-refresh-time).

		$ cp xbar/plugins/input-selector.sh ~/Libraries/Application\ Support/xbar/plugins/input-selector.1m.sh

3. Refresh xbar plugins
