#RCAutomate.com
#Partial SCCM Patch monitoring script
#After the deployment and the deployment policy have been created on the server, clients receive the policy on the next policy evaluation cycle.

<#
Monitoring SCCM Software Deployment https://support.microsoft.com/en-us/help/3090265/using-log-files-to-track-the-software-update-deployment-process-in-sys

    Alternative: Instead of keeping a hawks eye on SCCM, Just come back a few hrs after patching, run a script to check uptime
    Record Update Readiness Before install
    Sitting Waiting Status Flag
    SCCM Installation Complete - Pending Reboot
    Tail WindowsUpdate.log
    Rescanning Progress
    Detecting New Patches
    Scan Complete, None found, or some found
#>

echo "Policy Evaluation Cycle"
sls "Initializing download of policy" C:\Windows\CCM\Logs\PolicyAgent*.log

#policy and the deadline schedule are evaluated.
echo "policy and the deadline schedule are evaluated"
sls "will fire at" C:\Windows\CCM\Logs\Scheduler.log

#At the scheduled deadline, Scheduler notifies the Updates Deployment Agent to initiate the Deployment Evaluation process, as shown in Scheduler.log
echo "Sending message for schedule"
sls "Machine/DEADLINE" C:\Windows\CCM\Logs\Scheduler.log

#Updates Deployment Agent starts the Deployment Evaluation process by requesting a Software Update scan to make sure that the deployed updates are still applicable.
echo "Deployment Evaluation Scan"