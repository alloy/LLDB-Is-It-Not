# You want to load your project specific settings for LLDB, init?

LLDB normally loads a `.lldbinit` file that it finds in the current working directory. Unfortunately, Xcode lacks this
behaviour. (Filed as 📡 [rdar://23671344](https://openradar.appspot.com/23671344).)

This Xcode plugin will look in the project root (where you keep your `xcworkspace` or `xcodeproj`) for a `.lldbinit`
file and load it.

That’s it.

### Install

Install it either through [Alcatraz](http://alcatraz.io) or manually:

* `git clone https://github.com/alloy/LLDB-Is-It-Not.git`
* Open the Xcode project.
* Perform the build command.
* Restart Xcode.
