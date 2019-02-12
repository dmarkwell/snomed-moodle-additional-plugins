# Upload presentation metadata #

Upload presentation metadata from a CSV file

## Description ##

The Upload presentation metadata settings plugin for Moodle allows you add or update metadata for a presentation.

## Requirements ##

This plugin requires Moodle 2.9+ from https://moodle.org


## Installation and Update ##

Install the plugin, like any other plugin, to the following folder:

    /admin/tool/uploadmetadata

See http://docs.moodle.org/33/en/Installing_plugins for details on installing Moodle plugins.

There are no special considerations required for updating the plugin.

### Uninstallation ###

Uninstall the plugin by going into the following:

__Administration &gt; Site administration &gt; Plugins &gt; Plugins overview__

...and click Uninstall. You may also need to manually delete the following folder:

    /admin/tool/uploadmetadata

## Usage &amp; Settings ##

There are no configurable settings for this plugin.

Use the command __Administration &gt; Site administration &gt; Courses &gt; Upload block settings__
to upload a CSV file containing lines of the form:

The format of the CSV file must be as follows:

* First line must be:  #uploadmetadata
* Second line must be: fileref,title,metadata
* Each line of the file after the first two must contain one record.
* Each record is a series of data items in a fixed order separated by commas.
* The columns are: fileref,title,metadata with the following data:
* - fileref : name of file (no extension). Must match regular expression '^[A-Z]{3}[0-9]{4}[a-z]{0,2}_SomeCamelCaseTitle'
* - title : the title of the items typically title case representation of the fileref without the prefixing identifier.
* - metadata : HTML text that creates the metadata table displayed for the course activity. Complete with buttons for help and issue reporting, etc.

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
