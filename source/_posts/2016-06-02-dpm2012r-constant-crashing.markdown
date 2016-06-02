---
layout: post
title: "System Center Data Protection Manager 2012 R2 Always Crashing"
date: 2016-06-02T09:00-06:00
comments: true
categories:
- Data Protection Manager 2012 R2
---

DPM is great for backing up Microsoft stuff but I ran into something
really, really odd. In short, the msdpm kept crashing. I took a while
but I was eventually able to track down which object was causing the
crash by trying each failed sync one at a time. (DPM troubleshooting
step 1.) For the record, it was the system protection for a Windows
Server 2012 R2 server but I'm not convinced that that matters. On the
plus side, the eventlog on the DPM server was nearly useless.

    Log Name:      Application
    Source:        MSDPM
    Date:          6/1/2016 2:55:45 PM
    Event ID:      999
    Task Category: None
    Level:         Error
    Keywords:      Classic
    User:          N/A
    Computer:      srvdpm2.ad.adams.edu
    Description:
    The description for Event ID 999 from source MSDPM cannot be found. Either the component that raises this event is not installed on your local computer or the installation is corrupted. You can install or repair the component on the local computer.
    
    If the event originated on another computer, the display information had to be saved with the event.
    
    The following information was included with the event: 
    
    An unexpected error caused a failure for process 'msdpm'.  Restart the DPM process 'msdpm'.
    
    Problem Details:
    <FatalServiceError><__System><ID>19</ID><Seq>6871</Seq><TimeCreated>6/1/2016 8:55:45 PM</TimeCreated><Source>DpmThreadPool.cs</Source><Line>163</Line><HasError>True</HasError></__System><ExceptionType>FormatException</ExceptionType><ExceptionMessage>Input string was not in a correct format.</ExceptionMessage><ExceptionDetails>System.FormatException: Input string was not in a correct format.
       at System.Text.StringBuilder.AppendFormat(IFormatProvider provider, String format, Object[] args)
       at System.String.Format(IFormatProvider provider, String format, Object[] args)
       at Microsoft.Internal.EnterpriseStorage.Dls.Trace.TraceProvider.Trace(TraceFlag flag, String fileName, Int32 fileLine, Guid* taskId, Boolean taskIdSpecified, String formatString, Object[] args)
       at Microsoft.Internal.EnterpriseStorage.Dls.WriterHelper.SystemStateWriterHelper.RenameBMRReplicaFolderIfNeeded(String roFileSpec)
       at Microsoft.Internal.EnterpriseStorage.Dls.WriterHelper.SystemStateWriterHelper.ValidateROListOnPreBackupSuccess(Message msg, RADataSourceStatusType raDatasourceStatus, Guid volumeBitmapId, List`1&amp; missingVolumesList, ReplicaDataset&amp; lastFullReplicaDataset, ROListType&amp; roList)
       at Microsoft.Internal.EnterpriseStorage.Dls.Prm.ReplicaPreBackupBlock.ValidateROList(Message msg, RADataSourceStatusType raDatasourceStatus, Guid datasetId)
       at Microsoft.Internal.EnterpriseStorage.Dls.Prm.ReplicaPreBackupBlock.RAPreBackupSuccess(Message msg)
       at Microsoft.Internal.EnterpriseStorage.Dls.TaskExecutor.Fsm.Engine.ChangeState(Message msg)
       at Microsoft.Internal.EnterpriseStorage.Dls.TaskExecutor.TaskInstance.Process(Object dummy)
       at Microsoft.Internal.EnterpriseStorage.Dls.TaskExecutor.FsmThreadFunction.Function(Object taskThreadContextObj)
       at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state, Boolean preserveSyncCtx)
       at System.Threading.ExecutionContext.Run(ExecutionContext executionContext, ContextCallback callback, Object state, Boolean preserveSyncCtx)
       at System.Threading.QueueUserWorkItemCallback.System.Threading.IThreadPoolWorkItem.ExecuteWorkItem()
       at System.Threading.ThreadPoolWorkQueue.Dispatch()</ExceptionDetails></FatalServiceError>
    
    
    the message resource is present but the message is not found in the string/message table
    
    Event Xml:
    <Event xmlns="http://schemas.microsoft.com/win/2004/08/events/event">
      <System>
        <Provider Name="MSDPM" />
        <EventID Qualifiers="0">999</EventID>
        <Level>2</Level>
        <Task>0</Task>
        <Keywords>0x80000000000000</Keywords>
        <TimeCreated SystemTime="2016-06-01T20:55:45.000000000Z" />
        <EventRecordID>44561</EventRecordID>
        <Channel>Application</Channel>
        <Computer>srvdpm2.ad.adams.edu</Computer>
        <Security />
      </System>
      <EventData>
        <Data>An unexpected error caused a failure for process 'msdpm'.  Restart the DPM process 'msdpm'.
    
    Problem Details:
    &lt;FatalServiceError&gt;&lt;__System&gt;&lt;ID&gt;19&lt;/ID&gt;&lt;Seq&gt;6871&lt;/Seq&gt;&lt;TimeCreated&gt;6/1/2016 8:55:45 PM&lt;/TimeCreated&gt;&lt;Source&gt;DpmThreadPool.cs&lt;/Source&gt;&lt;Line&gt;163&lt;/Line&gt;&lt;HasError&gt;True&lt;/HasError&gt;&lt;/__System&gt;&lt;ExceptionType&gt;FormatException&lt;/ExceptionType&gt;&lt;ExceptionMessage&gt;Input string was not in a correct format.&lt;/ExceptionMessage&gt;&lt;ExceptionDetails&gt;System.FormatException: Input string was not in a correct format.
       at System.Text.StringBuilder.AppendFormat(IFormatProvider provider, String format, Object[] args)
       at System.String.Format(IFormatProvider provider, String format, Object[] args)
       at Microsoft.Internal.EnterpriseStorage.Dls.Trace.TraceProvider.Trace(TraceFlag flag, String fileName, Int32 fileLine, Guid* taskId, Boolean taskIdSpecified, String formatString, Object[] args)
       at Microsoft.Internal.EnterpriseStorage.Dls.WriterHelper.SystemStateWriterHelper.RenameBMRReplicaFolderIfNeeded(String roFileSpec)
       at Microsoft.Internal.EnterpriseStorage.Dls.WriterHelper.SystemStateWriterHelper.ValidateROListOnPreBackupSuccess(Message msg, RADataSourceStatusType raDatasourceStatus, Guid volumeBitmapId, List`1&amp;amp; missingVolumesList, ReplicaDataset&amp;amp; lastFullReplicaDataset, ROListType&amp;amp; roList)
       at Microsoft.Internal.EnterpriseStorage.Dls.Prm.ReplicaPreBackupBlock.ValidateROList(Message msg, RADataSourceStatusType raDatasourceStatus, Guid datasetId)
       at Microsoft.Internal.EnterpriseStorage.Dls.Prm.ReplicaPreBackupBlock.RAPreBackupSuccess(Message msg)
       at Microsoft.Internal.EnterpriseStorage.Dls.TaskExecutor.Fsm.Engine.ChangeState(Message msg)
       at Microsoft.Internal.EnterpriseStorage.Dls.TaskExecutor.TaskInstance.Process(Object dummy)
       at Microsoft.Internal.EnterpriseStorage.Dls.TaskExecutor.FsmThreadFunction.Function(Object taskThreadContextObj)
       at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state, Boolean preserveSyncCtx)
       at System.Threading.ExecutionContext.Run(ExecutionContext executionContext, ContextCallback callback, Object state, Boolean preserveSyncCtx)
       at System.Threading.QueueUserWorkItemCallback.System.Threading.IThreadPoolWorkItem.ExecuteWorkItem()
       at System.Threading.ThreadPoolWorkQueue.Dispatch()&lt;/ExceptionDetails&gt;&lt;/FatalServiceError&gt;
    </Data>
      </EventData>
    </Event>

As you can see, it's super helpful. And by super helpful, I mean
totally unhelpful. So, it's DPM troubleshooting step number 2, remove
and re-add the system protection to the protection
group. Unfortunately, that didn't help.

There's another log entry about two entries up from the one I posted that tried to be helpful.

    Log Name:      Application
    Source:        Windows Error Reporting
    Date:          6/1/2016 2:55:48 PM
    Event ID:      1001
    Task Category: None
    Level:         Information
    Keywords:      Classic
    User:          N/A
    Computer:      srvdpm2.ad.adams.edu
    Description:
    Fault bucket , type 0
    Event Name: DPMException
    Response: Not available
    Cab Id: 0
    
    Problem signature:
    P1: msdpm
    P2: 4.2.1205.0
    P3: msdpm.exe
    P4: 4.2.1205.0
    P5: System.FormatException
    P6: System.Text.StringBuilder.AppendFormat
    P7: 9F6A23D0
    P8: 
    P9: 
    P10: 
    
    Attached files:
    C:\Windows\Temp\tmp541A.xml
    C:\Program Files\Microsoft System Center 2012 R2\DPM\DPM\Temp\MSDPMCurr.errlog.2016-06-01_20-55-45.Crash
    
    These files may be available here:
    
    
    Analysis symbol: 
    Rechecking for solution: 0
    Report Id: 36bbe16a-283b-11e6-80c9-2c600c6007a0
    Report Status: 262144
    Hashed bucket: 
    Event Xml:
    <Event xmlns="http://schemas.microsoft.com/win/2004/08/events/event">
      <System>
        <Provider Name="Windows Error Reporting" />
        <EventID Qualifiers="0">1001</EventID>
        <Level>4</Level>
        <Task>0</Task>
        <Keywords>0x80000000000000</Keywords>
        <TimeCreated SystemTime="2016-06-01T20:55:48.000000000Z" />
        <EventRecordID>44563</EventRecordID>
        <Channel>Application</Channel>
        <Computer>srvdpm2.ad.adams.edu</Computer>
        <Security />
      </System>
      <EventData>
        <Data>
        </Data>
        <Data>0</Data>
        <Data>DPMException</Data>
        <Data>Not available</Data>
        <Data>0</Data>
        <Data>msdpm</Data>
        <Data>4.2.1205.0</Data>
        <Data>msdpm.exe</Data>
        <Data>4.2.1205.0</Data>
        <Data>System.FormatException</Data>
        <Data>System.Text.StringBuilder.AppendFormat</Data>
        <Data>9F6A23D0</Data>
        <Data>
        </Data>
        <Data>
        </Data>
        <Data>
        </Data>
        <Data>
    C:\Windows\Temp\tmp541A.xml
    C:\Program Files\Microsoft System Center 2012 R2\DPM\DPM\Temp\MSDPMCurr.errlog.2016-06-01_20-55-45.Crash</Data>
        <Data>
        </Data>
        <Data>
        </Data>
        <Data>0</Data>
        <Data>36bbe16a-283b-11e6-80c9-2c600c6007a0</Data>
        <Data>262144</Data>
        <Data>
        </Data>
      </EventData>
    </Event>

The important bit there is the .Crash file. Well, sort of. I jumped to
the end of the file as I would normally do with a log file and I saw
this.

    180C	280C	06/01	20:55:45.690	09	everettexception.cpp(761)		8AE83798-7A85-466A-80CA-22CA66582965	CRITICAL	Exception Message = Input string was not in a correct format. of type System.FormatException, process will terminate after generating dump

That's what's killing the service but it's not super helpful. I spent
a couple of hours running that down but it was a false trail. The real
culprit was this message that was up a ways in the log.

    180C	280C	06/01	20:54:55.393	09	AppAssert.cs(130)		8AE83798-7A85-466A-80CA-22CA66582965	WARNING	value of non-nullable parameter @RecoverableObjectMachineName is null

That's interesting. Even more interesting is the fact that Google gave
me zero results when I searched for "value of non-nullable parameter
@RecoverableObjectMachineName is null". Now I'm getting somewhere
... or not.

Actually, that provided a bit of a hint. For some reason, the machine
name is not being set on the object. As you may be able to tell, DPM
kinda expects the machine name to be set.

The solution was DPM troubleshooting step number 3, remove all of the
protected items and reinstall the agent. I may or may not have
sacrificed a rubber chicken at this point.

I added the system protection items back into DPM and
waited. Actually, as it was the end of the day, I went home and played
Star Wars Battlefront. When I came back in the morning everything was
still up and running. No crashes and a successful backup. I call that
a win!
