# Info
Place your modules here. 

Don't forget to add the module to Config.lua

# Structure
The below shows every possible VM/Hook that is possible within a module.

* NS2 ModLoader Hooks
    * Pre
        * Loads the script **before** the vanilla file
    * Post
        * Loads the script **after** the vanilla file
    * Replace
        * Replaces the vanilla file with the script
    * Halt 
        * Prevents the execution of the vanilla script
* VMs
    * Client
        * Runs all scripts in this folder on the Client VM
    * Server
        * Runs all scripts in this folder on the Server VM
    * Predict
        * Runs all scripts in this folder on the Predict VM
    * Shared
        * Runs all scripts in this folder on all VMs.
* ModFramework 
    * NewScripts
        * Loads all scripts in this folder on all VMs **before** any `Shared` scripts are loaded.
    * Scripts
        * Directory to place scripts. To load them use ModFramework function (TBA)