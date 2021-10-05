# Cuis-Smalltalk-CronDaemon

* Provides something similar to Unix **cron** daemon to run inside Cuis Smalltalk.
* It makes possible to run a **block** every time a time Duration elapses. For example: run something every 2 hours.

## How does it work

* When instantiated **CronDaemon**  runs a background process, this process checks if any **CronUnit** subclass
  instance is ready to be run. If so, it runs it.
* There are two subclasses of **CrontUnit**, namely **CronUnitEvery** (which runs a process every X time amount) and
  **CronUnitAt** which runs at specific times&dates (this at the moment is not implemented).
* You can make only one instance of **CronDaemon** which is accessible via `CronDaemon default`.
* `CronDaemon default` can be *enabled* or *disabled*, by default it is created in **disabled** state. 
* **CronUnit** instances can be *enabled* or *disabled*, by default they are created in **enabled** state.
* Differently from Unix *cron*, *CronDaemon* isn't stateless. It remembers last time a CronUnit has been run, for example.
* **CronDaemon defaut**, stores in itself all the **CronUnit** that it needs to control in the instance variable *unitList*. 
* The units are checked for runnability in the same order they are listed in the instance variable *unitList*. 

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



## TODO 
* Run something at specifics time and/or date, that is, implement **CronUnitAt**.


