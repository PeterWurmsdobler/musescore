# Simplicior

The objective of `Simplicior` is to make sheet music a bit simpler, less complex, and hence sight reading, too. Based on [Reducing the Cognitive Load in Reading Piano Sheet Music](https://medium.com/@peter-wurmsdobler/reducing-the-cognitive-load-in-reading-piano-sheet-music-a513aba01304), this plugin allows a combination of:

- use only one clef class throughout for all voices width adaptive octave offsets in order to minimise ledger lines and keep notes mostly within a staff;
- don't use double sharps or double flats and simply use the enharmonic equivalents, i.e. force the affected notes to be cast as their harmonic equivalent;
- primary notes (white keys on the piano) altered in pitch through sharps or flats (black keys on the piano):
  - change notehead colour (configurabl), e.g. red for flats, and blue for sharps,
  - change notehead shape and position, e.g. square and slightly offset.


## Notation issues

Western musical notation evolved over more that 1000 years, as described in [European Music Notation: History, Deficiencies and Alternatives](https://peter-wurmsdobler.medium.com/european-music-notation-history-deficiencies-and-alternatives-2684fd947aee); it accommodates all kinds of music and as such is as complex as it needs to be. 
For instance, Ludwig van Beethoven, Sonate №8, “Pathétique”, Opus 13, 1st Movement, 1st bar shows the use of sharps and flats in the key of C minor (3 flats):

![BarBlack](images/sonata-traditional.png)

The ambiguity of traditional notation is obvious: one position on the staff can mean three different notes (and keys), or one key can be represented by two different positions (and notes), depending on key signature as shown below:

![Traditional](images/traditional-notation-issues.png)

## Mititgation

For some applications, this notation could be adapted and small modification could address some shortcomings while remaining compatible with the traditional notation system. They could lower the entrance barrier and reduce the cognitive load on our brain.

### One Clef Class Only

The simple rule is to use only one clef, the treble clef as it is the most common. Since it is always difficult to read notes on ledger lines, additional shift the affected bars by the necessary number of octaves into a more legible area inside the staff, without switching offsets too often (a balance to be had).

![SingleClef](images/sonata-single-clef.png)


### Colour-Coded non-naturals

If a piece is written with sharps or flats (non-naturals), an affected note later down the staff on a line or space does not sound as written at that point, something hard to keep in mind for a beginner. Colouring those flats and sharps shows which notes are altered in what way:

![BarColour](images/sonata-colour-coded.png)


### Shape-Coded Non-Naturals

Alternatively, or in addition to colouring non-naturals (including accidentals), those notes can be encoded through shape and position in a configurable manner. This allows a unique one-to-one mapping between symbol and note (tone), hence helping the mind to read: 

![SingleClef](images/sonata-shape-coded.png)


## Installation

### MuseScore 3.x & 4.x

Install by copying the `Simplicior` folder into your MuseScore Plugins directory, then enable it with `ManagePlugins` from the MuseScore Plugins menu. 

## Usage

Selecting `Simplicior` from the MuseScore plugins menu opens up a dialogue window. There you can:

- select which of the simplification measures explained above should be applied,
- in case the colour option is selected, choose the colour for flats and sharps,
- in case the single clef option is selected, enter minimum number of bars. 