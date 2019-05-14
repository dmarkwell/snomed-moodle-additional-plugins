# Tool Simple Form #

SNOMED Video Popup

## Description ##

For displaying a YouTube video in a SNOMED International popup.

URL Usage and Parameters:

To start a YouTube video in the popup use the following URL pattern:

[moodle-server-url]/local/videopopup/index.php?cmid=[moodle-course-module-id]&videoid=[youtube-id-for-video]&mode=[mode]

For example
https://elearning.ihtsdotools.org/local/videopopup/index.php?cmid=1822&videoid=0LHr8Ihc4Ko&mode=course

With mode=course (as shown above) on closing the popup window the Moodle course view will revert to the Course Section containing the identified course module. 

To prevent this action from occuring (e.g. from a SCORM presentation)  omit the mode parameter (or as a future option use another parameter).

For example
https://elearning.ihtsdotools.org/local/videopopup/index.php?cmid=1822&videoid=0LHr8Ihc4Ko

## Requirements ##

This plugin requires Moodle 3.4+ from https://moodle.org


## Installation and Update ##

Install the plugin, like any other plugin, to the following folder:

    /local/videopopup

See http://docs.moodle.org/33/en/Installing_plugins for details on installing Moodle plugins.

There are no special considerations required for updating the plugin.

### Uninstallation ###

Uninstall the plugin by going into the following:

__Administration &gt; Site administration &gt; Plugins &gt; Plugins overview__

...and click Uninstall. You may also need to manually delete the following folder:

    /local/videopopup

## Usage &amp; Settings ##

There are no configurable settings for this plugin.

## License ##

2019 David Markwell SNOMED International

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
