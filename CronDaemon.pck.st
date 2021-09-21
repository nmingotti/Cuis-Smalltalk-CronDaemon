'From Cuis 5.0 [latest update: #4868] on 21 September 2021 at 6:29:48 pm'!
'Description '!
!provides: 'CronDaemon' 1 1!
SystemOrganization addCategory: #CronDaemon!


!classDefinition: #CronDaemon category: #CronDaemon!
Object subclass: #CronDaemon
	instanceVariableNames: 'updateTime lastRun'
	classVariableNames: 'Default'
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronDaemon class' category: #CronDaemon!
CronDaemon class
	instanceVariableNames: ''!

!classDefinition: #CronRow category: #CronDaemon!
Object subclass: #CronRow
	instanceVariableNames: 'initTime lastRun runEvery runAt'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'CronDaemon'!
!classDefinition: 'CronRow class' category: #CronDaemon!
CronRow class
	instanceVariableNames: ''!


!CronDaemon commentStamp: '<historical>' prior: 0!
This obejct mirrors the crond daemon in Unix systems. When time passes it check 
if any instantiated CronUnit needs to be run.
. It is a singleton class. There will be only one CronDaemon running on you SmalltalkImage.
---- instance variable ----- 
. updateTime. TimeInterval CronDaemon will wait before performing another check.!

!CronRow commentStamp: '<historical>' prior: 0!
As a single line in a crontab file this object represent something that must be executed
at some point in time in the future or every X time units.
!

!CronDaemon methodsFor: 'as yet unclassified' stamp: 'NM 9/21/2021 18:26:09'!
dispatcher
	^ nil 
	! !

!CronDaemon methodsFor: 'as yet unclassified' stamp: 'NM 9/21/2021 18:26:45'!
initialize
	updateTime _ Duration seconds: 30. 
	lastRun _ DateAndTime now. 
	". "
	". Kill other existing 'CronDeamon' processes, if they exist.   " 
	Process allSubInstancesDo: [ :pr | 
		(pr name = 'CronDaemon' ) ifTrue: [  pr terminate  ]
		].
	". Run the 'CronDaemon' background process  "	
        [ [true] whileTrue: [
		(Delay forDuration: updateTime ) wait.
		Transcript log: ('--> Crondawmon dispatcher runs now \n' printf: {} ).
		self dispatcher . 
	]
       ] forkAt: (ProcessorScheduler userBackgroundPriority) named: 'CronDaemon'. 
       ". "
	Default _ self! !

!CronDaemon class methodsFor: 'instance creation' stamp: 'NM 9/21/2021 18:10:12'!
default
	^ Default 
	! !

!CronDaemon class methodsFor: 'instance creation' stamp: 'NM 9/21/2021 17:36:00'!
new
	^ super new initialize 
	! !
