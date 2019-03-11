# Theory of explanations

To collaborate effectively with humans in complex, dynamic domains, robots need the ability to explain their knowledge, decisions, and experience in human-understandable terms.

To support this premise, this repository contains code for a system for agent explanation.

# Requirements

Runs on SWI-Prolog version 7.5.8 or greater in a Windows OS. Not tested with other operating systems.

# Installation

Clone the repository or extract the files from the zip archive in the directory structure given.

# Use

The main file is 'control_loop2019.pl'.

Run this file in Prolog and follow the instructions provided; calling the top-level command 'control_loop.' presents the full standard functionality. 'reset.' unloads the domain file in order to load another, and 'tone.' toggles between a more or less formal explanatory tone. 'test.' and 'time_tests(Out, N, V1, V2, V3).' are alternatives to control_loop that run experimental trials and are explained more fully within the program.

To use your own custom domains compatible with this system, you should replace the clauses
'read_ASP_program_and_translate_to_predicates'
and
'read_ASP_output_and_translate_to_predicates'
as appropriate.
