# Cuis-Smalltalk-CronDaemon

* Provides something similar to Unix **cron** daemon to run inside Cuis Smalltalk.
* It makes possible to run a **aBlock** every time:
  *  a time Duration elapses. For example: run something every 2 hours. Use **CronUnitEvery**. 
  *  wall clock displays time 'XX:YY'. Use  **CronUnitAt** .  
  *  aBlock evaluates to true. Use **CronUnitOn** . 
* You decide the **frequency** the CronDeamon does its checks, 30 seconds is the reccomended value. 

## How does it work

* When instantiated **CronDaemon**  runs a background process, this process checks if any **CronUnit** subclass
  instance is ready to be run. If so, it runs it.
* There are three subclasses of **CrontUnit**: **CronUnitEvery** (which runs a process every X time amount) and
  **CronUnitAt** which runs at specific times&dates (this at the moment takes only HH:MM input format) and **CronUnitOn** which runs when
  some aBlock evaluates to true. 
* **CrontUnitOn** is the most versatile unit and let you do what you want. But you must check the *timeDelta* mechanism
  to prevent multiple runs of the unit is compatible with your project.  
* You can make only one instance of **CronDaemon** which is accessible via `CronDaemon default`.
* `CronDaemon default` can be *enabled* or *disabled*, by default it is created in **disabled** state. 
* **CronUnit** instances can be *enabled* or *disabled*, by default they are created in **enabled** state.
* Differently from Unix *cron*, *CronDaemon* isn't stateless. It remembers last time a CronUnit has been run, for example.
* **CronDaemon defaut**, stores in itself all the **CronUnit** that it needs to control in the instance variable *unitList*. 
* The units are checked for runnability in the same order they are listed in the instance variable *unitList*. 
  That is, if at some time 2 or more units are ready to run you can always say who will run first.

## Examples 

* These examples are a copy of what is available in the **CronDaemon>>README**. 
```smalltalk 
				
". Create the CronDaemon which wakes up every 2 seconds to check what units has to be run
. NOTE. 2 seconds is a very short time, it is just an example for test, you may want to put a longer time period.
"
CronDaemon new: (Duration seconds: 2).
" . the CronDaemon is created in disabled state, to make it work you must enable it. "
CronDaemon default enable. 
" . You may want to see when the CronDaemon wakes up and check who has to be run."
CronDaemon default transcriptLogQ: true. 	


cu1 _ CronUnitEvery new: (Duration seconds: 5) name: 'test-1' 
	              do: [  Transcript log: '---> run test-1' . ] .
CronDaemon default addUnit: cu1.

cu2 _ CronUnitEvery new: (Duration seconds: 10) name: 'test-2' 
	              do: [  Transcript log: '---> run test-2' . ] .
CronDaemon default addUnit: cu2.
		
". see registered units, see also other methods in protocol: 'manageUnits'' "
CronDaemon default listUnits .			


". disable / enable a CronUnit. "
cu1 disable. 
cu1 enable.

". disable / enable the CronDaemon "
CronDaemon default disable. 
CronDaemon default enable. 

". disable/enable logging daemon runs in Transcript " 
CronDaemon default transcriptLogQ: false. 
CronDaemon default transcriptLogQ: true. 

```




