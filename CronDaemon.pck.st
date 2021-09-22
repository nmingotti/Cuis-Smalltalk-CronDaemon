'From Cuis 5.0 [latest update: #4878] on 23 September 2021 at 12:16:10 am'!
'Description '!
!provides: 'CronDaemon' 1 15!
SystemOrganization addCategory: #CronDaemon!


!classDefinition: #CronDaemon category: #CronDaemon!
Object subclass: #CronDaemon
	instanceVariableNames: 'process updateEvery lastRun transcriptLogQ'
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
	instanceVariableNames: 'runAt'
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

!CronUnit methodsFor: 'accessing' stamp: 'NM 9/22/2021 23:12:18'!
name
	^ name 
	! !

!CronUnitEvery methodsFor: 'initialization' stamp: 'NM 9/22/2021 23:55:50'!
printOn: aStream
        aStream 
                nextPutAll: self class name;
                nextPutAll: ' - ';
                nextPutAll: self name.  ! !

!CronDaemon methodsFor: 'initialization' stamp: 'NM 9/22/2021 11:06:52'!
initialize
	self initialize: (Duration seconds: 30) ! !

!CronDaemon methodsFor: 'initialization' stamp: 'NM 9/22/2021 15:05:41'!
initialize: aDuration
	". if there was an existing daemon destroy it.  "
	Default ifNotNil: [CronDaemon default destroy].
	updateEvery _ aDuration. 
	". by default the CronDaemon does not log it's activity to Transcript"
	transcriptLogQ _ false. 
	lastRun _ DateAndTime now. 
	". make a new the process, still not activate   "
	process _     [ [true] whileTrue: [
		(Delay forDuration: updateEvery ) wait.
		transcriptLogQ ifTrue: [
		       Transcript log: ('CronDaemon | dispatcher runs at: {1} {2}' format: {DateAndTime now. String lf.} ) ]. 
		self dispatcher . 
	]
       ] newProcess .
	process name: 'CronDaemon'.
	process priority: (ProcessorScheduler userBackgroundPriority ).
	". set the Default class variable, this is a singleton class . "
	Default _ self
! !

!CronDaemon methodsFor: 'README' stamp: 'NM 9/23/2021 00:13:51'!
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
		
				
cu1 _ CronUnitEvery new: (Duration seconds: 3) name: 'test unit 1' 
				    do: [ Transcript log: 'running unit 1' ] .
		
cu2 _ CronUnitEvery new: (Duration seconds: 12) name: 'test unit 2' 
				 do: [ Transcript log: 'running unit 2' ] .

CronDaemon default listAllUnits . 

". disable / enable a CronUnit"
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

!CronDaemon methodsFor: 'inspecting' stamp: 'NM 9/22/2021 15:48:31'!
listAllUnits
	". return a list of all CronUnit instances.  "
	|out|
	out _ OrderedCollection new. 
	CronUnit allSubclassesDo: [ :cla | 
		cla allInstancesDo: [ :inst | out add: inst ] ] .
	^ out 

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

!CronDaemon methodsFor: 'work' stamp: 'NM 9/22/2021 15:52:57'!
dispatcher
	". visit all instances of CronUnit and if time has come, run their associated code. "
	CronUnit allSubclassesDo: [ :cla | 
		cla allInstancesDo: [ :unit | unit tryToRun ] ] .
	! !

!CronDaemon class methodsFor: 'testing' stamp: 'NM 9/23/2021 00:01:18'!
isValidUnitName: aString
	". check if aString can be a valid unit name, that is, there is not other CronUnit with that name. "
	CronUnit allSubclasses do: [ :cla |
		cla allInstancesDo: [ :inst | (inst name = aString) ifTrue: [ ^ false ] ] ].
	^ true! !

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

!CronUnitEvery methodsFor: 'initialization' stamp: 'NM 9/22/2021 12:13:50'!
initialize: aDuration name: aString do: aBlock 
	action _ aBlock.
	runEvery _ aDuration .
	lastRun _ nil. 
	isActive _ true.
	name _ aString.
	initTime _ DateAndTime now.
	^ self ! !

!CronUnitEvery methodsFor: 'running' stamp: 'NM 9/22/2021 10:54:13'!
isTimeToRun
	". datermine if it is time for this unit to be run, return a boolean. "
	|now|
	"never runned units are always ready for a first  run."
	(lastRun isNil) ifTrue: [  ^ true ].  
	now _ DateAndTime now.
	((now - lastRun) >= runEvery) ifTrue: [ ^ true ].
	^ false 
	! !

!CronUnitEvery methodsFor: 'running' stamp: 'NM 9/22/2021 10:59:04'!
tryToRun
	". run this unit if its time has come and it is active"
	((self isActive) and: [self isTimeToRun]) ifTrue: [  
		action value. 
		lastRun _ DateAndTime now.
		] .
	
	 ! !

!CronUnitEvery class methodsFor: 'instance creation' stamp: 'NM 9/23/2021 00:07:20'!
new: aDuration name: aString do: aBlock
	self assert: [ CronDaemon isValidUnitName: aString ] description: 'CronUnit name must be not in use.' .
	^ super new initialize: aDuration name: aString do: aBlock! !
