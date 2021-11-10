'From Cuis 5.0 [latest update: #4908] on 10 November 2021 at 4:46:58 pm'!
'Description '!
!provides: 'CronDaemon' 1 24!
!requires: 'AskLinux' 1 6 nil!
SystemOrganization addCategory: #CronDaemon!


!classDefinition: #CronDaemon category: #CronDaemon!
Object subclass: #CronDaemon
	instanceVariableNames: 'process updateEvery lastRun transcriptLogQ unitList'
	classVariableNames: 'Default'
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronDaemon class' category: #CronDaemon!
CronDaemon class
	instanceVariableNames: ''!

!classDefinition: #CronUnit category: #CronDaemon!
Object subclass: #CronUnit
	instanceVariableNames: 'action initTime lastRun isActive name'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronUnit class' category: #CronDaemon!
CronUnit class
	instanceVariableNames: ''!

!classDefinition: #CronUnitAt category: #CronDaemon!
CronUnit subclass: #CronUnitAt
	instanceVariableNames: 'runAt delta'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronUnitAt class' category: #CronDaemon!
CronUnitAt class
	instanceVariableNames: ''!

!classDefinition: #CronUnitEvery category: #CronDaemon!
CronUnit subclass: #CronUnitEvery
	instanceVariableNames: 'runEvery'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronUnitEvery class' category: #CronDaemon!
CronUnitEvery class
	instanceVariableNames: ''!

!classDefinition: #CronUnitOn category: #CronDaemon!
CronUnit subclass: #CronUnitOn
	instanceVariableNames: 'runOn delta'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronUnitOn class' category: #CronDaemon!
CronUnitOn class
	instanceVariableNames: ''!

!classDefinition: #DateAndTimeHelper category: #CronDaemon!
Object subclass: #DateAndTimeHelper
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'DateAndTimeHelper class' category: #CronDaemon!
DateAndTimeHelper class
	instanceVariableNames: ''!


!CronDaemon commentStamp: '<historical>' prior: 0!
This obejct mirrors the crond daemon in Unix systems. When time passes it checks 
if any instantiated CronUnit needs to be run.
. It is a singleton class. 
. There will be only one CronDaemon running on your SmalltalkImage and it is
  CronDaemon default.
. See example in the CronDaemon#README




!

!CronUnitAt commentStamp: '<historical>' prior: 0!
. A CronUnit is runnable at specific times, dates, days.
. It can be recurrent or one shot
!

!CronUnitEvery commentStamp: '<historical>' prior: 0!
. A CronUnit that is runnable every time a Duration elapses. For example, we want to run it every hour.
!

!CronUnitOn commentStamp: '<historical>' prior: 0!
. A CronUnit is runnable at specific times, dates, days.
. It can be recurrent or one shot
!

!DateAndTimeHelper commentStamp: '<historical>' prior: 0!
. This class was introduced in 10-Nov-2021 because Cuis was not able 
to follow the correct time zone after a daylight time change. 
. Thereforse we call the date and time through this class which permits
to call Cuis functions or, maybe Linux services directly. !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/22/2021 23:12:18'!
name
	^ name 
	! !

!CronUnitAt methodsFor: 'printing' stamp: 'NM 10/14/2021 15:33:54'!
printOn: aStream
        aStream 
                nextPutAll: self class name;
                nextPutAll: ' - ';
                nextPutAll: self name.  ! !

!CronUnitEvery methodsFor: 'printing' stamp: 'NM 9/22/2021 23:55:50'!
printOn: aStream
        aStream 
                nextPutAll: self class name;
                nextPutAll: ' - ';
                nextPutAll: self name.  ! !

!CronUnitOn methodsFor: 'printing' stamp: 'NM 10/14/2021 16:17:29'!
printOn: aStream
        aStream 
                nextPutAll: self class name;
                nextPutAll: ' - ';
                nextPutAll: self name.  ! !

!CronDaemon methodsFor: 'initialization' stamp: 'NM 9/22/2021 11:06:52'!
initialize
	self initialize: (Duration seconds: 30) ! !

!CronDaemon methodsFor: 'initialization' stamp: 'NM 11/10/2021 16:36:25'!
initialize: aDuration
	". if there was an existing daemon destroy it.  "
	Default ifNotNil: [CronDaemon default destroy].
	updateEvery _ aDuration. 
	". by default the CronDaemon does not log it's activity to Transcript"
	transcriptLogQ _ false. 
	lastRun _ DateAndTimeHelper dateNow. 
	unitList _ OrderedCollection new. 
	". make a new the process, still not activate   "
	process _     [ [true] whileTrue: [
		(Delay forDuration: updateEvery ) wait.
		transcriptLogQ ifTrue: [
		       Transcript log: ('CronDaemon | dispatcher runs at: {1} {2}' format: {DateAndTimeHelper dateNow. String lf.} ) ]. 
		self dispatcher . 
	]
       ] newProcess .
	process name: 'CronDaemon'.
	process priority: (ProcessorScheduler userBackgroundPriority ).
	". set the Default class variable, this is a singleton class . "
	Default _ self
! !

!CronDaemon methodsFor: 'README' stamp: 'NM 10/5/2021 16:47:30'!
README
	|cu1 cu2|
	self disableCode: [
		
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


". this is only to avoid the editor telliing me fake variables are useless, ignore it. "		
^ {cu1. cu2}		
		
		
		
		
		
		
		
		
		].! !

!CronDaemon methodsFor: 'inspecting' stamp: 'NM 9/22/2021 12:01:35'!
disable
	(self status = 'enabled') ifTrue:[ self process suspend ] ifFalse: [
		Transcript log: 'Error. CronDaemon already disabled, command ignored.' . 
		].
 	! !

!CronDaemon methodsFor: 'inspecting' stamp: 'NM 9/22/2021 12:02:00'!
enable
	(self status = 'disabled') ifTrue:[ self process resume ] ifFalse: [
		Transcript log: 'Error. CronDaemon already enabled, command ignored.' . 
		].
 	! !

!CronDaemon methodsFor: 'inspecting' stamp: 'NM 9/22/2021 11:47:59'!
status
	^ (self process isSuspended) ifTrue: [ 'disabled' ] ifFalse: [ 'enabled' ].
	! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 11:30:52'!
lastRun
	"Answer the value of lastRun"

	^ lastRun! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 11:30:52'!
lastRun: anObject
	"Set the value of lastRun"

	lastRun _ anObject! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 11:30:52'!
process
	"Answer the value of process"

	^ process! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 11:30:52'!
process: anObject
	"Set the value of process"

	process _ anObject! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 14:45:53'!
transcriptLogQ
	"Answer the value of transcriptLogQ"

	^ transcriptLogQ! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 14:45:53'!
transcriptLogQ: anObject
	"Set the value of transcriptLogQ"

	transcriptLogQ _ anObject! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 10/5/2021 11:23:21'!
unitList
	"Answer the value of unitList"

	^ unitList! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 10/5/2021 11:23:21'!
unitList: anObject
	"Set the value of unitList"

	unitList _ anObject! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 11:30:52'!
updateEvery
	"Answer the value of updateEvery"

	^ updateEvery! !

!CronDaemon methodsFor: 'accessing' stamp: 'NM 9/22/2021 11:30:52'!
updateEvery: anObject
	"Set the value of updateEvery"

	updateEvery _ anObject! !

!CronDaemon methodsFor: 'finalization' stamp: 'NM 9/22/2021 15:07:13'!
destroy
	". destroy existing instance of CronDaemon, in particular wipe out its process. "
	CronDaemon default process suspend.
	CronDaemon default process terminate.
	Default _ nil .! !

!CronDaemon methodsFor: 'manageUnits' stamp: 'NM 10/5/2021 16:14:34'!
addUnit: aCronUnit
	". add a cronUnit under the daemon to be started when needed ."
	unitList add: aCronUnit .! !

!CronDaemon methodsFor: 'manageUnits' stamp: 'NM 10/5/2021 16:15:44'!
listUnits
	"list know units under CronDeamon control "
	^ unitList ! !

!CronDaemon methodsFor: 'manageUnits' stamp: 'NM 10/5/2021 16:24:45'!
removeAllUnits
	". remove all units from CronD control "
	unitList _ OrderedCollection new. ! !

!CronDaemon methodsFor: 'manageUnits' stamp: 'NM 10/5/2021 16:22:02'!
removeUnitAt: anIndex
	". Remove a unit from Crond control ."
	unitList removeAt: anIndex .! !

!CronDaemon methodsFor: 'work' stamp: 'NM 10/5/2021 11:25:42'!
dispatcher
	". visit all instances of CronUnit and if time has come, run their associated code. "
	unitList do: [ :unit | unit tryToRun ].
	
	" . previous version which had not the variable 'unitList' . "
	"CronUnit allSubclassesDo: [ :cla | 
		cla allInstancesDo: [ :unit | unit tryToRun ] ] . "
	! !

!CronDaemon class methodsFor: 'instance creation' stamp: 'NM 9/21/2021 18:10:12'!
default
	^ Default 
	! !

!CronDaemon class methodsFor: 'instance creation' stamp: 'NM 9/21/2021 17:36:00'!
new
	^ super new initialize 
	! !

!CronDaemon class methodsFor: 'instance creation' stamp: 'NM 9/22/2021 11:30:07'!
new: aDuration
	^ super new initialize: aDuration 
	! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/21/2021 18:53:44'!
action
	"Answer the value of action"

	^ action! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/21/2021 18:53:44'!
action: anObject
	"Set the value of action"

	action _ anObject! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/21/2021 18:53:44'!
initTime
	"Answer the value of initTime"

	^ initTime! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/21/2021 18:53:44'!
initTime: anObject
	"Set the value of initTime"

	initTime _ anObject! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/22/2021 10:53:17'!
isActive
	"Answer the value of isActive"

	^ isActive! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/22/2021 10:53:17'!
isActive: anObject
	"Set the value of isActive"

	isActive _ anObject! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/21/2021 18:53:44'!
lastRun
	"Answer the value of lastRun"

	^ lastRun! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/21/2021 18:53:44'!
lastRun: anObject
	"Set the value of lastRun"

	lastRun _ anObject! !

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/22/2021 10:53:17'!
name: anObject
	"Set the value of name"

	name _ anObject! !

!CronUnit methodsFor: 'status' stamp: 'NM 9/22/2021 12:18:49'!
disable
	isActive _ false.! !

!CronUnit methodsFor: 'status' stamp: 'NM 9/22/2021 12:18:35'!
enable
	isActive _ true.! !

!CronUnit methodsFor: 'status' stamp: 'NM 9/22/2021 12:20:06'!
status
	^ (isActive = true) ifTrue: [ 'enabled' ]  ifFalse: [ 'disabled' ]  ! !

!CronUnitAt methodsFor: 'running' stamp: 'NM 11/10/2021 16:30:31'!
tryToRun
	". run this unit if its time has come and it is active"
	((self isActive) and: [self isTimeToRun]) ifTrue: [  
		action value. 
		lastRun _ DateAndTimeHelper dateNow .
		] .
	! !

!CronUnitAt methodsFor: 'initialization' stamp: 'NM 11/10/2021 16:32:46'!
initializeAtTime: aStringTime name: aStringName do: aBlock
	action _ aBlock.
	runAt _ Time fromString: aStringTime.
	delta _ Duration minutes: 1.
	lastRun _ nil. 
	isActive _ true.
	name _ aStringName.
	initTime _ DateAndTimeHelper dateNow.
	^ self ! !

!CronUnitAt methodsFor: 'initialization' stamp: 'NM 11/10/2021 16:29:52'!
isTimeToRun
	". datermine if it is time for this unit to be run, return a boolean. "
	|now diff|
	"per never runned units"
	(lastRun isNil) ifTrue: [
		diff _   ((DateAndTimeHelper timeNow) - runAt) .
		". siamo poco dopo l'ora X,  poco significa 1 delta " 
		^ ((diff > (Duration seconds: 1)) and: [ (diff < delta) ]) 
	].  
	" . se la unit ha girato almeno una volta " 
	" . se il tempo dalla ultima volta che ha girato e' < 2*delta allora non e' ora di considerarla "
	now _ DateAndTimeHelper dateNow. 
	((now - lastRun) < (delta * 2)) ifTrue: [ ^ false ]  ifFalse: [
		diff _   ((DateAndTimeHelper timeNow) - runAt) .
		". siamo poco dopo l'ora X,  poco significa 1 delta " 
		^ ((diff > (Duration seconds: 1)) and: [ (diff < delta) ]) 	
		].
	! !

!CronUnitAt class methodsFor: 'as yet unclassified' stamp: 'NM 10/14/2021 15:13:02'!
newAtTime: aStringTime name: aStringName do: aBlock
	". Example of aStringTime: '15:26'  ' "
	^ self basicNew initializeAtTime: aStringTime name: aStringName  do: aBlock . ! !

!CronUnitEvery methodsFor: 'initialization' stamp: 'NM 11/10/2021 16:32:24'!
initialize: aDuration name: aString do: aBlock 
	action _ aBlock.
	runEvery _ aDuration .
	lastRun _ nil. 
	isActive _ true.
	name _ aString.
	initTime _ DateAndTimeHelper dateNow.
	^ self ! !

!CronUnitEvery methodsFor: 'running' stamp: 'NM 11/10/2021 16:30:57'!
isTimeToRun
	". datermine if it is time for this unit to be run, return a boolean. "
	|now|
	"never runned units are always ready for a first  run."
	(lastRun isNil) ifTrue: [  ^ true ].  
	"now _ DateAndTime now."
	now _ DateAndTimeHelper dateNow.
	((now - lastRun) >= runEvery) ifTrue: [ ^ true ].
	^ false 
	! !

!CronUnitEvery methodsFor: 'running' stamp: 'NM 11/10/2021 16:31:12'!
tryToRun
	". run this unit if its time has come and it is active"
	((self isActive) and: [self isTimeToRun]) ifTrue: [  
		action value. 
		lastRun _ DateAndTimeHelper dateNow.
		] .
	
	 ! !

!CronUnitEvery class methodsFor: 'instance creation' stamp: 'NM 10/5/2021 16:11:09'!
new: aDuration name: aString do: aBlock
        ". Questo controllo non e' piu' necessario perche' ora le units vegono inserite 
             in una lista in CronDaemon per essere attivate . "
	"self assert: [ CronDaemon isValidUnitName: aString ] description: 'Errore, cron unit con questo nome in uso' ."
	^ self basicNew initialize: aDuration name: aString do: aBlock! !

!CronUnitOn methodsFor: 'running' stamp: 'NM 11/10/2021 16:31:53'!
tryToRun
	". run this unit if its time has come and it is active"
	((self isActive) and: [self isTimeToRun]) ifTrue: [  
		action value. 
		lastRun _ DateAndTimeHelper dateNow.
		] .
	! !

!CronUnitOn methodsFor: 'initialization' stamp: 'NM 11/10/2021 16:32:10'!
initializeOn: aBlockTest name: aStringName do: aBlockAction
	action _ aBlockAction.
	runOn _ aBlockTest .
	delta _ Duration minutes: 1.
	lastRun _ nil. 
	isActive _ true.
	name _ aStringName.
	initTime _ DateAndTimeHelper dateNow.
	^ self ! !

!CronUnitOn methodsFor: 'initialization' stamp: 'NM 11/10/2021 16:31:38'!
isTimeToRun
	". datermine if it is time for this unit to be run, return a boolean. "
	|now |
	"per never runned units"
	(lastRun isNil) ifTrue: [
		^ runOn value.
	].  
	" . se la unit ha girato almeno una volta " 
	" . se il tempo dalla ultima volta che ha girato e' < 2*delta allora non e' ora di considerarla "
	"now _ DateAndTime now. "
	now _ DateAndTimeHelper dateNow.
	((now - lastRun) < (delta * 2)) ifTrue: [ ^ false ]  ifFalse: [
		^ runOn value. 
		].
	! !

!CronUnitOn class methodsFor: 'as yet unclassified' stamp: 'NM 10/14/2021 16:29:40'!
newOn: aBlockTest name: aStringName do: aBlockAction
	". Example of aStringTime: '15:26'  ' "
	^ self basicNew initializeOn: aBlockTest name: aStringName  do: aBlockAction . ! !

!DateAndTimeHelper class methodsFor: 'as yet unclassified' stamp: 'NM 11/10/2021 16:28:09'!
dateNow
	". by default should use `DateAndTime now` "
	" ^ DateAndTime now "
	^ LinuxShell date! !

!DateAndTimeHelper class methodsFor: 'as yet unclassified' stamp: 'NM 11/10/2021 16:27:15'!
timeNow
	". by default should use `Time now` "
	" ^ Time now "
	^ LinuxShell time ! !
