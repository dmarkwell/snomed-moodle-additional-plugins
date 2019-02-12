# Upload scheduler appointment slots #

Upload scheduler appointment slot settings from a CSV file

## Description ##

Allows insertion of new mdl_scheduler_slots from a CSV file.

## Requirements ##

This plugin requires Moodle 2.9+ from https://moodle.org


## Installation and Update ##

Install the plugin, like any other plugin, to the following folder:

    /admin/tool/uploadschedulerappts

See http://docs.moodle.org/33/en/Installing_plugins for details on installing Moodle plugins.

There are no special considerations required for updating the plugin.

### Uninstallation ###

Uninstall the plugin by going into the following:

__Administration &gt; Site administration &gt; Plugins &gt; Plugins overview__

...and click Uninstall. You may also need to manually delete the following folder:

    /admin/tool/uploadschedulerappts

## Usage &amp; Settings ##

There are no configurable settings for this plugin.

Use the command __Administration &gt; Site administration &gt; Courses &gt; Upload scheduler appointments__
to upload a CSV file containing lines of the form:

The format of the CSV file must be as follows:

* First line must be:  #uploadschedulerappts
* Second line must be: schedulerid,starttime,duration,tutor,timeanddateUrl,timeanddateText,webinarUrl,exclusivity
* Each line of the file after the first two must contain one record.
* Each record is a series of data items in a fixed order separated by commas.
* The required fields are schedulerid, starttime, duration, tutor, timeanddateUrl, timeanddateText, webinarUrl, exclusivity.';

## License ##

2018 David Markwell SNOMED International

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
