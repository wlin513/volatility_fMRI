5#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division
from psychopy import locale_setup, sound, gui, visual, core, data, event, logging
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys  # to get file system encoding
import copy, time, os, sys, random #from the std python libs
from comppsychHelper import *
import psychopy.visual
import math
import pyglet

#from psychopy.tools.filetools import fromFile, toFile

# control variables

leftkey='1';
rightkey='2';
controlkey='s';
triggerkey='5';
ntrigger=4        # number of trigger to start the task

leftstimx=-6    # x position left stimulus
rightstimx=6    # x position right stimulus
stimy=0         # y position main stimuli
outy=2.2        # y distance between main stimulus and outcome text
stimsize=1.8    # size of stimuli
boxwidth=1.6    # width of choice box
fixdur=1        # duration of fixation in secs
maxchoicedur=5  # maximum duration of choice in secs
monitordur=1    # duration of monitor in secs
outcomedur=3   # duration of outcome in secs (if not jittered)
totmon=1.5      # starting amount of money
winloss=0.15    # amount won or lost per trial
stimlets=['a','F','G','h','K','o','m','S']      # letters to be used as stimuli
nblk=4        # number of blocks in total
trinumperblk=80 # number of trials in a block

main_dir='C:\\STIM_USERS\\wanjun\\2018_fMRI\\'
#main_dir='E:\\2018_fMRI\\'
os.chdir(main_dir)

# Store info about the experiment session
# date as month, day hour min
dateStr = time.strftime("%b_%d_%H%M", time.localtime())#add the current time
expName = 'Dynamic_learning_fMRI'  # from the Builder filename that created this script
expInfo = {'Subject Num':'', 'nattempt':1,'startBlk':1}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False:
    core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

# get subject number and training type
#enterSubjInfo(expInfo, 'simple voltrain experiment')
subnum=int(expInfo['Subject Num'])

blktype=subnum%8
if blktype==0:
    blktype==8
    
ifrevnum=math.ceil(subnum*1.0/8)%2
if ifrevnum==1:
    ifreverse=1
else:
    ifreverse=2
    
#make a text file to save data
filename = 'Dynamic_learning_fMRI_'+expInfo['Subject Num'] + '_blktype_' + str(blktype) +'_rev_'+str(ifreverse)+'_ntry_'+str(expInfo['nattempt'])
trfilename = 'TR_Dynamic_learning_fMRI_'+expInfo['Subject Num'] + '_blktype_' + str(blktype) +'_rev_'+str(ifreverse)+'_ntry_'+str(expInfo['nattempt'])
dataFile = open(os.path.join(main_dir,'results',filename+'.txt'), 'w')#a simple text file with 'taba-separated-values'
TRFile=open(os.path.join(main_dir,'results',trfilename+'.txt'), 'w')#recording TR onsets
# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=None,
    savePickle=True)

endExpNow = False  # flag for 'escape' or other condition => quit the exp

schedfilename='fMRI_sched_sub_'+expInfo['Subject Num']+'.xlsx'

Sched=data.importConditions(os.path.join(main_dir,'schedules',schedfilename))
#Sched=data.importConditions(os.path.join(main_dir,'schedules','2_opt_linkeed_4trial_demo_quickpilot.xlsx'))#2_opt_linkeed_4trial_demo_quickpilot

# data collected for each trial
trialdat=['Trialnumber','Winpos','Losspos','Side','ITIjitter','ISIjitter','Choice','RT','Choiceside','Winchosen','LossChosen','TotalMoney','Fixationonset_TR','Fixationonset_Total','Choiceonset_TR','Choiceonset_Total',
'Chosenoptiononset_TR','Chosenoptiononset_Total','Outcomesonset_TR','Outcomesonset_Total','stima','stimb']

# write basic info, task parameters and headers
writeToFile(dataFile,['Subject Num',expInfo['Subject Num'],'BlockType',blktype,'ifReverse',ifreverse,'ntry',expInfo['nattempt'],'date',dateStr])
writeToFile(dataFile,trialdat)
writeToFile(TRFile,['ntr','onsettime'])
#create window and stimuli55555
# Setup the Window

monsize=(1920,1080)

#win = visual.Window(
#    monsize, fullscr=True, screen=1,
#    allowGUI=False, allowStencil=False,
#    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
#    blendMode='avg', useFBO=True)

win = visual.Window(monsize,fullscr=True,allowGUI=False,allowStencil=False, monitor='testMonitor', units='deg', screen=1)
# store frame rate of monitor if we can measure it
expInfo['frameRate'] = win.getActualFrameRate()

if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0  # could not measure, so guess
    
stima = visual.TextStim(win,text='a', units='deg', color='black',font='agathodaimon',height=stimsize)
stimb = visual.TextStim(win,text='b', units='deg', color='black',font='agathodaimon',height=stimsize)
choicebox=visual.ShapeStim(win, units='deg', lineWidth=4, fillColor='grey', lineColor='black',fillColorSpace='rgb', vertices=((-boxwidth, -boxwidth), (-boxwidth, boxwidth), (boxwidth, boxwidth),(boxwidth,-boxwidth)))
misschoicebox=visual.ShapeStim(win, units='deg', lineWidth=4, fillColor='grey', lineColor='yellow',fillColorSpace='rgb', vertices=((-boxwidth, -boxwidth), (-boxwidth, boxwidth), (boxwidth, boxwidth),(boxwidth,-boxwidth)))
winmes=visual.TextStim(win,text='win',colorSpace='rgb',color=[0.0, 1.0, 0.0])
lossmes=visual.TextStim(win,text='loss',colorSpace='rgb',color=[1.0, 0.0 ,0.0])
fixation = visual.TextStim(win,text='X',color='black')
#tottext=visual.TextStim(win,text=u'Total \xa3'+ str(totmon),units='deg',color='black',height=1, pos=(0.0,-2))
tottext=visual.TextStim(win,text=u'Total \xa3'+'%0.2f'%totmon, units='deg',color='black',height=1, pos=(0.0,-2))

#Initiate eye-tracker link and open EDF
#trackname=expInfo['Subject Num'][0:4]+'_t'
#tracker = pylinkwrapper.Connect(win, trackname)   # note edf filename must be less than 9 characters. Use this and then rename on transfer. If you need to get it off the eyelink, look for file which is first 5 lets of subname then _t

# set up stim
random.shuffle(stimlets)
stimcount=0
stima.setText(stimlets[stimcount])
stimb.setText(stimlets[stimcount+1])
stimb.setText(stimlets[stimcount+1])


#timer for task
taskclock=core.Clock()# to track the time since experiment started
taskclock.reset()

# Create some handy timers
countDown = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 
Sblk=expInfo['startBlk'];
ntr=0;
for i in range(Sblk, nblk+1):
    totntrial=(i-1)*trinumperblk;
    stima.setText(stimlets[stimcount])
    stimb.setText(stimlets[stimcount+1])
    stimcount=stimcount+2
    
    #display instructions and wait
    #pauseclick("Press left or right to select a shape\nTry to win as much money as possible\n\nClick Either Button to Start",win,mouse)
    # Start Code - component code to be run before the window creation

    text = psychopy.visual.TextStim(
        win=win,
        text="Press left or right to select a shape\nTry to win as much money as possible\nPlease don't move or sleep during the scanning\n\n Continue?",
        color=[-1, -1, -1]
    )

    text.draw()
    win.flip()            
    psychopy.event.waitKeys(maxWait=2000, keyList=controlkey, modifiers=False, timeStamped=False)
    trialClock = core.Clock()
    # Initialize components for Trigger
    
    text = psychopy.visual.TextStim(
        win=win,
        text="Waiting for the scanner",
        color=[-1, -1, -1]
    )
    text.draw()
    win.flip()
    psychopy.event.waitKeys(maxWait=2000, keyList=triggerkey, modifiers=False, timeStamped=False)
    TRclock=core.Clock()
    TRclock.reset()
    
    TRonset=taskclock.getTime()
    ntr+=1
    writeToFile(TRFile,list([ntr,TRonset]))
    
    # set up handler to look after randomisation of conditions etc
    trigger_loop = data.TrialHandler(nReps=ntrigger, method='sequential', 
        extraInfo=expInfo, originPath=-1,
        trialList=[None],
        seed=None, name='trigger_loop')
    thisExp.addLoop(trigger_loop)  # add the loop to the experiment
    thisTrigger_loop = trigger_loop.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb = thisTrigger_loop.rgb)
    text = psychopy.visual.TextStim(
        win=win,
        text="Waiting for the scanner",
        color=[-1, -1, -1]
    )
        
    for thisTrigger_loop in trigger_loop:
        currentLoop = trigger_loop
        # abbreviate parameter names if possible (e.g. rgb = thisTrigger_loop.rgb)
        if thisTrigger_loop != None:
            for paramName in thisTrigger_loop.keys():
                exec(paramName + '= thisTrigger_loop.' + paramName)
        TRonset=taskclock.getTime()
        ntr+=1
        writeToFile(TRFile,list([ntr,TRonset]))
        # ------Prepare to start Routine "trial"-------
        t = 0
        trialClock.reset()  # clock
        frameN = -1
        continueRoutine = True
        # update component parameters for each repeat
        fivekey = event.BuilderKeyResponse()
        # keep track of which components have finished
        trialComponents = [text, fivekey]
        for thisComponent in trialComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        # -------Start Routine "trial"-------
        while continueRoutine:
            # get current time
            t = trialClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *text* updates
            if t >= 0.0 and text.status == NOT_STARTED:
                # keep track of start time/frame for later
                text.tStart = t
                text.frameNStart = frameN  # exact frame index
                text.setAutoDraw(True)
            
            # *fivekey* updates
            if t >= 0.0 and fivekey.status == NOT_STARTED:
                # keep track of start time/frame for later
                fivekey.tStart = t
                fivekey.frameNStart = frameN  # exact frame index
                fivekey.status = STARTED
                # keyboard checking is just starting
                event.clearEvents(eventType='keyboard')
            if fivekey.status == STARTED:
                theseKeys = event.getKeys(keyList=triggerkey)
                
                # check for quit:
                if "escape" in theseKeys:
                    endExpNow = True
                if len(theseKeys) > 0:  # at least one key was pressed
                    # a response ends the routine
                    continueRoutine = False
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in trialComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # -------Ending Routine "trial"-------
        for thisComponent in trialComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # the Routine "trial" was not non-slip safe, so reset the non-slip timer
        countDown.reset()
    # completed 10 repeats of 'trigger_loop'



    # ------Starting Task-------
    #start tracker
    #tracker.record_on()
    trialhandle=data.TrialHandler(Sched[totntrial:totntrial+trinumperblk], nReps=1, method='sequential', dataTypes=trialdat, extraInfo=None, seed=None, originPath=None, name='', autoLog=True)
    ntrial=0;
    escapekeys=[];
    for thistrial in trialhandle:
        #thistrial=trialhandle.next()
        trialhandle.data.add('Trialnumber',totntrial+1)
        # allow to escape window
        if "escape" in escapekeys:
            core.quit()
            
        trialclock=core.Clock()
        rtclock=core.Clock()
        trialclock.reset()
        
        
        # use for timing of stimuli
        #countDown = core.CountdownTimer()
        #countDown.add(fixdur)
        
        trialhandle.data.add('stima',stima.text)
        trialhandle.data.add('stimb',stimb.text)
        #-------------------------------------- present fixation cross
        
        fixation.draw()
        tottext.draw()
        win.flip()
        fixonset2task=taskclock.getTime()
        fixonset2tr=TRclock.getTime()
        trialhandle.data.add('Fixonset2task',fixonset2task)
        trialhandle.data.add('Fixonset2tr',fixonset2tr)
        #msg='Fixation trial %d' % (ntrial+1)
        #tracker.send_message(msg)
        countDown.reset()
        countDown.add(Sched[totntrial]['ITIjitter'])
        #countDown.add(random.randint(minjit, maxjit))
        
        while countDown.getTime()>0:
            keys = event.getKeys(keyList=triggerkey)
            escapekeys=event.getKeys(keyList=["escape"])
            if keys is not None:
                if triggerkey in keys:
                    TRonset=taskclock.getTime()
                    ntr+=1
                    writeToFile(TRFile,list([ntr,TRonset]))
                    keys=[]
            if "escape" in escapekeys:
                core.quit()
        
        
        #----------------------------------now present both stimuli until choice made
        if Sched[totntrial]['side'] == 1:
            stima.setPos([leftstimx,stimy])
            stimb.setPos([rightstimx,stimy])
        else:
            stimb.setPos([leftstimx,stimy])
            stima.setPos([rightstimx,stimy])
        
        
        fixation.draw()
        tottext.draw()
        stima.draw()
        stimb.draw()
        win.flip()

        choiceonset2task=taskclock.getTime()
        choiceonset2tr=TRclock.getTime()
        #msg='Choice trial %d' % (ntrial+1)
        #tracker.send_message(msg)
        trialhandle.data.add('choiceonset2task',choiceonset2task)
        trialhandle.data.add('choiceonset2tr',choiceonset2tr)
    # use for timing of stimuli
        countDown.reset()
        countDown.add(maxchoicedur)  
        rtclock.reset()
        psychopy.event.clearEvents(eventType='keyboard')
        left_press=False
        right_press=False
        theseKeys=[]
        while True not in (len(theseKeys)>0,countDown.getTime()<0):
            theseKeys =event.getKeys(keyList=[leftkey,rightkey],modifiers=False,timeStamped=False);
            escapekeys=event.getKeys(keyList=["escape"])
            if len(theseKeys)>0:
                rt=rtclock.getTime()
            keys = event.getKeys(keyList=triggerkey)
            if keys is not None:
                if triggerkey in keys:
                    TRonset=taskclock.getTime()
                    ntr+=1
                    writeToFile(TRFile,list([ntr,TRonset]))
                    keys=[]
            if "escape" in escapekeys:
                    core.quit()
                    
        if len(theseKeys)>0:
            if theseKeys[0][0]==leftkey:
                butpress='left'
            if theseKeys[0][0]==rightkey:
                butpress='right'
        if countDown.getTime()<0:
            rt=float('nan')
            butpress='none'
            
        while countDown.getTime ()>4: # minmum present time
            keys = event.getKeys(keyList=triggerkey)
            escapekeys=event.getKeys(keyList=["escape"])
            if keys is not None:
                if '5' in keys:
                    TRonset=taskclock.getTime()
                    ntr+=1
                    writeToFile(TRFile,list([ntr,TRonset]))
                    keys=[]
            if "escape" in escapekeys:
                    core.quit()

        #resp=event.waitKeys(keyList=['b','m'], timeStamped=rtclock)
        trialhandle.data.add('Choiceside', butpress)
        trialhandle.data.add('RT', rt)
        #                       put the choice box in the correct place, work out which option was chosen and whether a win and/or loss was received
        if butpress=='none':
            ch=np.random.choice(['left','right'],1,p=[0.5,0.5])
        else:
            ch=butpress
            
        if ch=='left':                                 #chose left option
            choicebox.setPos([leftstimx,stimy])
            misschoicebox.setPos([leftstimx,stimy])
            if Sched[totntrial]['side']==1:                # option 1 on left
                trialhandle.data.add('Choice',1)        #chose option 1
                if Sched[totntrial]['winpos']==1:          # win for option 1
                    trialhandle.data.add('Winchosen',1)
                    totmon=totmon+winloss
                else:
                    trialhandle.data.add('Winchosen',0)
                if Sched[totntrial]['losspos']==1:         # loss for option 1
                    trialhandle.data.add('Losschosen',1)
                    totmon=totmon-winloss
                else:
                    trialhandle.data.add('Losschosen',0)
            else:                                       # option 1 on right
                trialhandle.data.add('Choice',0)        # chose option 2
                if Sched[totntrial]['winpos']==1:          # win for option 1
                    trialhandle.data.add('Winchosen',0)
                else:
                    trialhandle.data.add('Winchosen',1)
                    totmon=totmon+winloss
                if Sched[totntrial]['losspos']==1:         # loss for option 1
                    trialhandle.data.add('Losschosen', 0)
                else:
                    trialhandle.data.add('Losschosen',1)
                    totmon=totmon-winloss
        else:                                           # chose right option
            choicebox.setPos([rightstimx,stimy])
            misschoicebox.setPos([rightstimx,stimy])
            if Sched[totntrial]['side']==1:  
                trialhandle.data.add('Choice',0)        #chose option 2
                if Sched[totntrial]['winpos']==1:          # win for option 1
                    trialhandle.data.add('Winchosen',0)
                else:
                    trialhandle.data.add('Winchosen',1)
                    totmon=totmon+winloss
                if Sched[totntrial]['losspos']==1:         # loss for option 1
                    trialhandle.data.add('Losschosen', 0)
                else:
                    trialhandle.data.add('Losschosen',1)
                    totmon=totmon-winloss
            else:                                       #chose option 1
                trialhandle.data.add('Choice',1)            #chose option 1
                if Sched[totntrial]['winpos']==1:           # win for option 1
                    trialhandle.data.add('Winchosen',1)
                    totmon=totmon+winloss
                else:
                    trialhandle.data.add('Winchosen',0)
                if Sched[totntrial]['losspos']==1:             # loss for option 1
                    trialhandle.data.add('Losschosen',1)
                    totmon=totmon-winloss
                else:
                    trialhandle.data.add('Losschosen',0)
            
        #                                      present participant choice if RT<1
        if butpress=='none':
            fixation.draw()
            tottext.draw()
            misschoicebox.draw()
            stima.draw()
            stimb.draw()
            win.flip()
        else:
            fixation.draw()
            tottext.draw()
            choicebox.draw()
            stima.draw()
            stimb.draw()
            win.flip()
        
        #msg='Monitor trial %d' % (ntrial+1)
        #tracker.send_message(msg)
        chosenoptiononset2task=taskclock.getTime()
        chosenoptiononset2tr=TRclock.getTime()
        trialhandle.data.add('Chosenoptiononset2task',chosenoptiononset2task)
        trialhandle.data.add('Chosenoptiononset2tr',chosenoptiononset2tr)
        countDown.reset()
        countDown.add(Sched[totntrial]['ISIjitter'])
        while countDown.getTime()>0:
            keys = event.getKeys(keyList=triggerkey)
            escapekeys=event.getKeys(keyList=["escape"])
            if keys is not None:
                if triggerkey in keys:
                    TRonset=taskclock.getTime()
                    ntr+=1
                    writeToFile(TRFile,list([ntr,TRonset]))
                    keys=[]
            if "escape" in escapekeys:
                core.quit()
        
        
        #                                                                                  present for outcome duration
        if Sched[totntrial]['winpos']==Sched[totntrial]['side'] and Sched[totntrial]['losspos']==Sched[totntrial]['side']:
            winmes.setPos([leftstimx,outy])
            lossmes.setPos([leftstimx,-outy])
        if Sched[totntrial]['winpos']==Sched[totntrial]['side'] and Sched[totntrial]['losspos']!=Sched[totntrial]['side']: 
            winmes.setPos([leftstimx,outy])
            lossmes.setPos([rightstimx,-outy])
        if Sched[totntrial]['winpos']!=Sched[totntrial]['side'] and Sched[totntrial]['losspos']==Sched[totntrial]['side']: 
            winmes.setPos([rightstimx,outy])
            lossmes.setPos([leftstimx,-outy])
        if Sched[totntrial]['winpos']!=Sched[totntrial]['side'] and Sched[totntrial]['losspos']!=Sched[totntrial]['side']: 
            winmes.setPos([rightstimx,outy])
            lossmes.setPos([rightstimx,-outy])
            
        if butpress=='none':
            fixation.draw()
            tottext.draw()
            misschoicebox.draw()
            stima.draw()
            stimb.draw()
            winmes.draw()
            lossmes.draw()
            win.flip()
        else:
            fixation.draw()
            tottext.draw()
            choicebox.draw()
            stima.draw()
            stimb.draw()
            winmes.draw()
            lossmes.draw()
            win.flip()
        
        outcomesonset2task=taskclock.getTime()
        outcomesonset2tr=TRclock.getTime()
        trialhandle.data.add('Outresonset2task',outcomesonset2task)
        trialhandle.data.add('Outresonset2tr',outcomesonset2tr)
        countDown.reset()
        countDown.add(outcomedur)
        while countDown.getTime()>0:
            keys = event.getKeys(keyList=triggerkey)
            escapekeys=event.getKeys(keyList=["escape"])
            if keys is not None:
                if '5' in keys:
                    TRonset=taskclock.getTime()
                    ntr+=1
                    writeToFile(TRFile,list([ntr,TRonset]))
                    keys=[]
            if "escape" in escapekeys:
                core.quit()
                    
        trialhandle.data.add('TotalMoney',totmon)
        tottext.setText(u'Total \xa3'+ '%0.2f'%totmon)
        # write data to a file at the end of each trial to make sure nothing is lost 
        td=trialhandle.data
        writeToFile(dataFile,list([int(td['Trialnumber'][ntrial]),Sched[totntrial]['winpos'],Sched[totntrial]['losspos'],Sched[totntrial]['side'],Sched[totntrial]['ITIjitter'],Sched[totntrial]['ISIjitter'],
        int(td['Choice'][ntrial]),float(td['RT'][ntrial]),"".join(td['Choiceside'][ntrial]),int(td['Winchosen'][ntrial]),int(td['Losschosen'][ntrial]),totmon,
        fixonset2tr,fixonset2task,choiceonset2tr,choiceonset2task,chosenoptiononset2tr,chosenoptiononset2task,outcomesonset2tr,outcomesonset2task,stima.text,stimb.text]))
        totntrial+=1
        ntrial+=1

            
text = psychopy.visual.TextStim(
               win=win,
               text="End of Task",
               color=[-1, -1, -1]
         )
text.draw()
win.flip()
psychopy.event.waitKeys(maxWait=20, keyList=['return'], modifiers=False, timeStamped=False)

#stop tracker
#tracker.record_off()
# Retrieve EDF
#tracker.end_experiment('C:\\Users\\epulcu\\Desktop\\wanjun\\vol_fMRI_psychopy\\results\\tracker')
#os.rename(os.path.join('C:\\Users\\epulcu\\Desktop\\wanjun\\vol_fMRI_psychopy\\results\\tracker\\',trackname+'.edf'),os.path.join('C:\\Users\\epulcu\\Desktop\\wanjun\\vol_fMRI_psychopy\\results\\tracker\\',fileName+'_tracker.edf'))

# just in case-- at end of task save all data again
trialhandle.saveAsText(os.path.join(main_dir,'results',filename), dataOut=['Choice_raw', 'Choiceside_raw','RT_raw', 'Winchosen_raw','Losschosen_raw'])

# -------Ending Task-------

# make sure everything is closed down
thisExp.abort()  # or data files will save again on exit
win.close()
core.quit()