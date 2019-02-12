# Tool Simple Form #

SNOMED Student Course Clear Form

## Description ##

For deleting the records of an identified student in a specified course.

The course is specified by its shortname.
The student is specified by their lastname and email as registered.
A confirm button must be selected for the clearance to occur.

The delete procedure called is ClearStudentCourseProgress()

The log records created by the process are reported on completion.

## Requirements ##

This plugin requires Moodle 2.9+ from https://moodle.org


## Installation and Update ##

Install the plugin, like any other plugin, to the following folder:

    /admin/tool/studentcourseclear

See http://docs.moodle.org/33/en/Installing_plugins for details on installing Moodle plugins.

There are no special considerations required for updating the plugin.

### Uninstallation ###

Uninstall the plugin by going into the following:

__Administration &gt; Site administration &gt; Plugins &gt; Plugins overview__

...and click Uninstall. You may also need to manually delete the following folder:

    /admin/tool/studentcourseclear

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
