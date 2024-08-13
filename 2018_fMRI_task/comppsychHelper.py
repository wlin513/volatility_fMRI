from psychopy import gui, visual
import os, random
import numpy as np

def popupError(text):
    errorDlg = gui.Dlg(title="Error", pos=(200,400))
    errorDlg.addText('Error: '+text, color='Red')
    errorDlg.show()
    
    
    
def writeToFile(fileHandle,trial,sync=True):
    """Writes a trial (array of lists) to a file. File needs to be opened outside the function. Pass in the filehandle as an argument"""
    line = '\t'.join([str(i) for i in trial]) #TABify
    line += '\n' #add a newline
    fileHandle.write(line)
    if sync:
        fileHandle.flush()
        os.fsync(fileHandle)
        
        

def enterSubjInfo(info,exptitle):
    optreceived=False
    dlg = gui.DlgFromDict(info,title=exptitle,fixed=['dateStr'])

    if dlg.OK:
        optreceived=True
        
    
    return(optreceived)
    

def flatjitter(minval,maxval,nbins=10):
    """ return a random number selected from a flat distribution"""
    numarr=np.arange(minval,maxval,(maxval-minval)/float(nbins))
    random.shuffle(numarr)
    return(numarr[0])
    
def pauseclick(str,win,mouse):
    """ print a message on the screen and wait for mouse click"""
    message1 = visual.TextStim(win, pos=[0,+3],text=str,color="black",units="deg",height=0.8)
    message1.draw()
    left_press=False
    right_press=False

    win.flip()#to show our newly drawn 'stimuli'
    #pause until there's a keypress
    while True not in (left_press, right_press):
        (left_press,middle_press,right_press)=mouse.getPressed()
        
    return()