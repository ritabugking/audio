#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 10 22:49:39 2017

@author: yijuwang
"""
import scipy
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
from pydub import AudioSegment
from pydub.utils import make_chunks
from pyAudioAnalysis import audioBasicIO as aIO
from pyAudioAnalysis import audioSegmentation as aS

# cut long file into small pieces
myaudio = AudioSegment.from_file("/Users/yijuwang/Desktop/spto/CL005.wav" , "wav") 
chunk_length_ms = 1000*60*10 # pydub calculates in millisec
chunks = make_chunks(myaudio, chunk_length_ms) #Make chunks of one sec

#Export all of the individual chunks as wav files
wavlist=[]
for i, chunk in enumerate(chunks):
    chunk_name = "chunk{0}.wav".format(i)
    chunk.export(chunk_name, format="wav")
    [Fs, x] = aIO.readAudioFile(chunk_name)
    segments = aS.silenceRemoval(x, Fs, 0.020, 0.020, smoothWindow = 1.0, Weight = 0.3, plot = True)
    #wavlist.append(segments)
  
#extract all sound into seperate file

for i in range(0, len(segments)):
#for i in range(0, len(segments), 1): 
    s=segments[i][0]*Fs
    e=segments[i][1]*Fs
    sound=x[int(s):int(e)]
    scipy.io.wavfile.write("song{0}.wav".format(i), Fs, sound)
     #downsampling
    a = sound
    R = 2
    a=a.reshape(-1,R).mean(axis=1)
 #plt.plot(sound)
    file_name = "song{0}.png".format(i)
    
    Pxx, freqs, bins, im = plt.specgram(a, NFFT=1024, Fs=44100/2, noverlap=900, cmap="gray_r") #Fs be downsampling 
    plt.axis('off')
    plt.savefig(file_name)
    plt.close()
#plt.show()

