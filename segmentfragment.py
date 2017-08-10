#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 17:44:49 2017

@author: yijuwang
"""

from pydub import AudioSegment
from pydub.utils import make_chunks
from pyAudioAnalysis import audioBasicIO as aIO
from pyAudioAnalysis import audioSegmentation as aS

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
    wavlist.append(segments)
  
    



