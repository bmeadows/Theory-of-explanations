# Theory of explanations

To collaborate effectively with humans in complex, dynamic domains, robots need the ability to explain their knowledge, decisions, and experience in human-understandable terms.

To support this premise, this repository contains code for a system for agent explanation.

# Requirements

Runs on SWI-Prolog version 7.4.0 or greater.

# Installation

Clone the repository or extract the files from the zip in the directory structure given.

# Use

The main file is 'control_loop2019.pl'.

Run this file in Prolog and call the top-level command 'test.', which gives an example of functionality using an example domain. To change to a different example domain, alter the name of the domain included at the top of the file.

To use your own custom domains compatible with this system, or for full functionality, replace the clauses
'read_ASP_program_and_translate_to_predicates'
and
'read_ASP_output_and_translate_to_predicates'
and then call 'control_loop.' from Prolog.

