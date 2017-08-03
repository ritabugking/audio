#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 17:44:49 2017

@author: yijuwang
"""

from pydub import AudioSegment
from pydub.utils import make_chunks

myaudio = AudioSegment.from_file("/Users/yijuwang/Desktop/spto/superlongfile.wav" , "wav") 
chunk_length_ms = 1000*60*10 # pydub calculates in millisec
chunks = make_chunks(myaudio, chunk_length_ms) #Make chunks of one sec

#Export all of the individual chunks as wav files

for i, chunk in enumerate(chunks):
    chunk_name = "chunk{0}.wav".format(i)
    chunk.export(chunk_name, format="wav")