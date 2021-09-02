#----------------------------------------------------------------------------
#             This is a sample Music Playback Settings profile
#----------------------------------------------------------------------------
#
# To use this file, execute MiDPLAY from the commandline like this:
# MP SAMPLE.MPS
#
# It may be used by anybody for any purpose !
# If you want your own player to use these MPS-files,
# do so to reach some kind of standard.
#
# --------------------------------------------------------
# ID    PARAMETER
# --------------------------------------------------------
# song: song-filename
# bank: SounFont-filename/s                     (optional)
# no:   bank number for SBK/s                   (optional)
# fx:   reverb- and chorus-settings             (optional)
# map:  channel mapping                         (optional)
# --------------------------------------------------------
#
# SONG:
# After that ID comes the filename of the song to play
# EXAMPLE
# song:foo.mid
# This is a minimal mps-file...
#
# BANK:
# Similiar to "SONG:" after this ID comes the filename of the bank to load.
# If more than one bank should be loaded, separate them with a comma !
# EXAMPLE
# song:foo.mid bank:hbert.sbk,ybert.sbk,pbert.sbk
# These SBKs would be loaded as userbank 1,2 and 3 !
# NOTE !
# It is recommended that synthesizer SoundFonts such as SYNTHGM.SBK are
# loaded as bank 0 !
#
# NO:
# Here we place the bank number/s for the SBKs to be loaded.
# EXAMPLE
# song:bar.mid bank:foo1.sbk,foo2.sbk no:1,20
# These banks would be loaded as userbank 1 and 20 !
#
# FX:
# The reverb- and chorus-settings can be as follows:
# ------------------------------------
#  REVERB                CHORUS
# ------------------------------------
#  Room1                 Chorus1
#  Room2                 Chorus2
#  Room3                 Chorus3
#  Hall1                 Chorus4
#  Hall2                 FeedbackDelay
#  Plate                 Flanger
#  Delay                 ShortDelay
#  PanningDelay          ShortDelayFB
# ------------------------------------
# EXAMPLE
# song:foo.mid fx:delay,flanger
#
# MAP:
# The channel mapping is done like this:
# --------------------
#  DEVICE          ID
# --------------------
#  EMU8000         E
#  MPU401          M
#  SB-MIDI         S
# --------------------
# If you want to have your EMU8000 on channels 1-9 and your MPU401 on
# channel 10 and to make it even more complicate you want your SB-MIDI
# on channels 11-16, here is how its done:
# EXAMPLE
# song:bar.mid map:EEEEEEEEEMSSSSSS
# Make sure you allways give 16 IDs to get a complete new mapping !
#
#
song:sample.mid bank:sample.sbk no:1 fx:chorus2 map:EEEEEEEEEEEEEEEE
