# Theory of explanations

To collaborate effectively with humans in complex, dynamic domains, robots need the ability to explain their knowledge, decisions, and experience in human-understandable terms.

To support this premise, this repository contains code for a system for agent explanation.

# Requirements

Runs on SWI-Prolog version 7.5.8 or greater in a Windows OS. Not tested with other operating systems.

# Installation

Clone the repository or extract the files from the zip in the directory structure given.

# Use

The main file is 'control_loop2019.pl'.

Run this file in Prolog and follow the instructions provided; calling the top-level command 'test.' demonstrates the possible plans generated using an example domain, while 'control_loop.' allow full standard functionality.

To use your own custom domains compatible with this system, replace the clauses
'read_ASP_program_and_translate_to_predicates'
and
'read_ASP_output_and_translate_to_predicates'.
