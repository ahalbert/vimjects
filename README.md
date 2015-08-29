#Vimjects

Project specific vim configurations for hackers. Checks your project's directory for `.vimjectsrc` files and sources them.

For example, you can add autocommands that automatically runs your projects build command on save, specific to each project.

###Features: 
* Recursivley searches the filesystem for .vimjectrc and .vimjectrcbuf files and sources them
* Rudimetery security features
* Completley customizable to your needs

##Installation

Vimjects is compatible with Pathogen and other Vim addon managers. I personally use [vim-plug](https://github.com/junegunn/vim-plug)

Just add

    Plug 'ahalbert/vimjects'

between the Plug calls in your .vimrc.

##Using Vimjects
Add a .vimjectrc file with the extra configuraiton options in the directoty of your project.

Vimjects will confirm you want to source this file before doing so.

By default, Vimjects will stop after sourcing 1 file. Calling `vimjects#continueSourcing()` in your .vimjectsrc when sourcing will tell Vimjects to source
the next file.

##Configuration options

#### `g:Vimjects_sourceall`
Values: `1` or `0`

If set to `1`, source all files given by the function without using vimjects#continueSourcing. If `0`, require `vimjects#continueSourcing()`  to source next file.

Default: `0`

#### `g:Vimjects_secure`
Values: `1` or `0`

If set to `1`, ask for confirmation is file has never been loaded or been changed since last loaded. If set to `0`, file is sourced without prompting

The hashes check if the file has changed since previous

Default: `1`

#### `g:Vimjects_source_function`
Values: Function signature

Function to be used to determine what files to source. Takes any number of args, and returns a list of files to source. If empty, will do
nothing.

Default: `vimjects#sourceRecursive`

## License
Copyright (c) Armand Halbert.  Distributed under the same terms as Vim itself.
See `:help license`.
