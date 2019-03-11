%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Section 1: Parameters %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Consult formatting and WordNet libraries
:- [pretty_printer].
:- [resources].

:- dynamic learningMode/1, last_transitions_failed/1, currently_believed_to_hold/1, currentTime/1, 
	currentTime_unaltered/1, currentGoal/1, obs/3, hpd/2, answer_set_goal/1, expected_effects/3, 
	user_alerted_interruption/0, representation_granularity/1, communication_specificity/1, 
	complexity_detail/1, reported/1, join_word/1, use_pov/1, self_described/0, use_formal_tone/1, 
	test_time_start/1.

:- discontiguous describe_outcomes/2.

use_formal_tone(false).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Section 2: Control %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

control_loop :-
	read_ASP_program_and_output_to_predicates,
	(get_user_explanation_request -> continue_to_explanation ; leave_loop).
	
leave_loop :-
	prettyprintln('Request not understood or no explanation requested. Leaving control loop.').

% Overwrite to translate a custom domain
read_ASP_program_and_output_to_predicates :-
	read_ASP_program_and_translate_to_predicates,
	read_ASP_output_and_translate_to_predicates.

continue_to_explanation :-
	generate_explanation,
	!,
	solicit_user_response.

solicit_user_response :- 
	get_text_feedback(Input),
	(process_user_input_text(Input) -> continue_to_explanation ; leave_loop).
solicit_user_response.

get_user_explanation_request :-
	get_text(Input),
	process_user_input_text(Input).

get_text(Input) :-
	prettyprintln('Please provide instruction (within single quotes followed by period): '),
	read(Input),
	prettyprintln(' '),
	Input \= [],
	Input \= '',
	Input \= '\n'.

get_text_feedback(Input) :-
	prettyprintln('Explanation finished. Please provide feedback (within single quotes followed by period): '),
	read(Input),
	prettyprintln(' '),
	Input \= [],
	Input \= '',
	Input \= '\n'.

initialise_for_reset :-
	retractall(reported(_)), retractall(self_described).

process_user_input_text(InputString) :-
	initialise_for_reset,
	% As long as a synonym for 'explain' appears, take the part before that and extract any specificity cue
	partition_input(InputString, Preamble, Tell, _Remainder),
	prettyprint('=> "'),
	prettyprint(Tell),
	prettyprintln('"'),
	change_specificity_from_cues(Preamble).
	
partition_input(InputStringX, Preamble, Tell, Remainder) :-
	string_lower(InputStringX, InputString), % Set all characters to lower case
	split_string_into_three_at_first_instance_of_a_word(InputString,
			["explain", "analyse", "analyze", "explanation", "describe", "tell", "repeat"],
			Preamble, Tell, Remainder),
	!.

split_string_into_three_at_first_instance_of_a_word(Input, WordList, Output1, Output2, Output3) :-
	member(Token, WordList),
	sub_string(Input, CharactersBefore, Length, CharactersAfter, Token), % Fixes place of a target word in the string
	sub_string(Input, 0, CharactersBefore, _, Output1),
	FirstParts is CharactersBefore + Length,
	sub_string(Input, FirstParts, CharactersAfter, 0, Output3),
	Output2 = Token,
	!.

% Replace the following clauses appropriately to encode other domains
read_ASP_program_and_translate_to_predicates :-
	true.
read_ASP_output_and_translate_to_predicates :-
	true.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Section 3: Cue parsing %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

change_specificity_from_cues(Text) :-
	establish_cues(Text, AxisOrGeneral, Direction), % Direction in {decrease_specificity, increase_specificity, standard_specificity}
	use_formal_tone(T),
	(T=true -> prettyprint('Axis of specificity indicated by user input: ') ; prettyprint('I will change the axis of ')),
	prettyprint(AxisOrGeneral),
	prettyprintln('.'),
	(T=true -> prettyprint('Direction of specificity indicated by user input: ') ; prettyprint('I will change this axis in the direction: ')),
	prettyprint(Direction),
	prettyprintln('.'),
	change_axes_based_on_cues(AxisOrGeneral, Direction).

change_axes_based_on_cues(_AxisOrGeneral, standard_specificity) :-
	!.
change_axes_based_on_cues(general, decrease_specificity) :-
	decrease_axis(representation_granularity),
	decrease_axis(communication_specificity),
	decrease_axis(complexity_detail),
	!.
change_axes_based_on_cues(general, increase_specificity) :-
	increase_axis(representation_granularity),
	increase_axis(communication_specificity),
	increase_axis(complexity_detail),
	!.
change_axes_based_on_cues(AxisOrGeneral, decrease_specificity) :-
	decrease_axis(AxisOrGeneral), !.
change_axes_based_on_cues(AxisOrGeneral, increase_specificity) :-
	increase_axis(AxisOrGeneral), !.

% Parse to find words indicating specificity + direction + negation
establish_cues(Preamble, AxisOrGeneral, Direction) :-
	set_preamble_specificity_word(Preamble, AxisOrGeneral, Spec),
	!,
	preamble_direction_word(Preamble, Direc),
	preamble_negation_words(Preamble, Negs),
	length(Negs,L), % An odd number of negations means overall negation
	MOD is mod(L,2),
	( (MOD == 1) -> (DirIndicator is (Spec * Direc * -1)) ; (DirIndicator is (Spec * Direc)) ), % 1 = increase specificity, -1 = decrease specificity
	( (DirIndicator == 1) -> Direction = increase_specificity ; true ),
	( (DirIndicator == -1) -> Direction = decrease_specificity ; true ),
	( (DirIndicator == 0) -> Direction = standard_specificity ; true ).
establish_cues(_, general, standard_specificity).

% % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % %

% Determine explanation axes to modulate

% 1 is specific, -1 is generic

% First, try to find a match using only exact matches, no WordNet ties
set_preamble_specificity_word(Preamble, AxisOrGeneral, Spec) :-
	preamble_specificity_word(Preamble, false, AxisOrGeneral, Spec),
	!.
% Only if that fails, try to find a match using WordNet ties
set_preamble_specificity_word(Preamble, AxisOrGeneral, Spec) :-
	preamble_specificity_word(Preamble, true, AxisOrGeneral, Spec),
	!.
% Finally if that fails, fall back on default (no change)
set_preamble_specificity_word(_Preamble, general, 0).

% Words indicating SPECIFICITY or ABSTRACTNESS
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["specify", "specific", "concrete", "concreteness", "grounded"]), Ret = communication_specificity, Spec = 1, !.
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["generic", "general", "abstract", "abstractness", "vague"]), Ret = communication_specificity, Spec = -1, !.

% Words indicating REPRESENTATION GRANULARITY (coarse/fine distinction)
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["fine", "fineness", "refined", "finegrained", "fine-grained, gritty"]), Ret = representation_granularity, Spec = 1, !. % "granular, granularity"
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["coarse", "coarseness", "coarsegrained", "coarse-grained"]), Ret = representation_granularity, Spec = -1, !.

% Words indicating QUANTITY of detail
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["thorough", "thoroughly", "elaborate", "extended", "extensively", "slowly"]), Ret = complexity_detail, Spec = 1, !.
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["brief", "briefly", "concise", "quick", "quicker", "fast", "faster", "speedily", "rapidly"]), Ret = complexity_detail, Spec = -1, !.

% (Default or tie: Assume change on all axes)
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["narrow", "narrowly", "bottom-up", "detail", "details", "detailed"]), Ret = general, Spec = 1, !.
preamble_specificity_word(Preamble, FollowWordNetLinks, Ret, Spec) :-
	contains_a_word(Preamble, FollowWordNetLinks, ["broad", "broadly", "top-down", "summary", "summarise", "summarize"]), Ret = general, Spec = -1, !.

% % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % %

% Determine direction of modulation

% Ambiguity: Signal magnitude increase
preamble_direction_word(Preamble, 1) :-
	contains_a_word(Preamble, true, ["much", "more", "increase", "increased", "considerable", "high", "maximum", "maximal"]),
	contains_a_word(Preamble, true, ["little", "reduce", "reduced", " less ", " low ", "minimum", "minimal"]),
	use_formal_tone(T),
	(T=true -> prettyprintln('(Increase or decrease in specificity ambiguous; defaulting)') ; prettyprintln('I am not sure if specificity should increase or decrease... Defaulting to increase.')),
	!.
% Negative words found: Signal magnitude decrease
preamble_direction_word(Preamble, -1) :-
	contains_a_word(Preamble, true, ["little", "reduce", "reduced", " less ", " low ", "minimum", "minimal"]),
	!.
% No words found or positive words found: Signal magnitude increase by default
preamble_direction_word(_Preamble, 1).

% List of terms that indicate negation
preamble_negation_words(Preamble, Negs) :-
	find_words(Preamble, ["absent", "without", "sans ", "not "], Negs).

find_words(Text, List, Negs) :- % Returns each instance of a target word found as a substring
	findall([A,B,C,L], (member(L, List), sub_string(Text, A, B, C, L)), Negs).

% True in the presence of a target word or a synonym for one
contains_a_word(Text, true, List) :-
	member(Word, List),
	related_to(Word, Word2), % Word2 returns as a const, which works with sub_string
	sub_string(Text, _, Length, _, Word2),
	Length >= 4, % Word2 has to be at least 4 characters to qualify (to lower false matches when a short synonym appears as part of an unrelated word).
	!.
contains_a_word(Text, false, List) :-
	member(Word, List),
	sub_string(Text, _, _Length, _, Word),
	!.
	
related_to(WordStr, Word2) :-
	term_string(Word,WordStr), % String to constant
	s(SID,_,Word,_,_,_),
	s(SID,_,Word2,_,_,_). % Any word in same group including itself
related_to(WordStr, Word2) :-
	term_string(Word,WordStr), % String to constant
	s(SID,_,Word,_,_,_),
	sim(SID,ID2),
	s(ID2,_,Word2,_,_,_),
	Word \= Word2.
related_to(WordStr, WordStr). % Each word related to itself - Covers cases where the word is not found in the wordnet data.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Section 4: Axes %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

representation_granularity(fine). % coarse, moderate, fine
communication_specificity(3). % 1, 2, 3, 4
complexity_detail(high). % low, medium, high

next_higher(coarse, moderate).
next_higher(moderate, fine).
next_higher(low, medium).
next_higher(medium, high).
next_higher(1,2).
next_higher(2,3).
next_higher(3,4).

set_axis(Axis, Value) :-
	functor(Term, Axis, 1),
	Term,
	retractall(Term),
	functor(Term2, Axis, 1),
	arg(1, Term2, Value),
	assert(Term2).
	
increase_axis(Axis) :- 
	functor(Term, Axis, 1),
	Term,
	arg(1, Term, CurrentValue),
	next_higher(CurrentValue, NewValue),
	retractall(Term),
	functor(Term2, Axis, 1),
	arg(1, Term2, NewValue),
	assert(Term2),
	!.
increase_axis(Axis) :-
	prettyprint('Unchanging (increase): '),
	prettyprintln(Axis).
decrease_axis(Axis) :- 
	functor(Term, Axis, 1),
	Term,
	arg(1, Term, CurrentValue),
	next_higher(NewValue, CurrentValue),
	retractall(Term),
	functor(Term2, Axis, 1),
	arg(1, Term2, NewValue),
	assert(Term2),
	!.
decrease_axis(Axis) :-
	prettyprint('Unchanging (decrease): '),
	prettyprintln(Axis).

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Section 5: Explanation generation %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_explanation :-
	goal_was_achieved,
	!,
	print_goal_time_prefix,
	prettyprint(' and accomplished in '),
	print_plan_length,
	prettyprintln(' time steps.'),
	print_action_sequence,
	prettyprintln('').

generate_explanation :-
	!,
	print_goal_time_prefix,
	prettyprint('. '),
	print_action_sequence,
	prettyprintln(' At this point, the plan failed.').

goal_was_achieved :-
	asp(goal(_)),
	!. % The goal was achieved at some timestep

print_goal_time_prefix :-
	prettyprint('The goal ("'),
	asp_goal_string(String),
	prettyprint(String),
	prettyprint('") was received before time '),
	earliest_time(T),
	prettyprint(T).

% % %

earliest_time(T) :-
	asp(holds(_,T)),
	not(( asp(holds(_,T2)), T2 < T )),
	!.
latest_operation_time(T) :-
	asp(fine(hpd(_,T))),
	not(( asp(fine(hpd(_,T2))), T2 > T )),
	!.

print_plan_length :-
	earliest_time(TStart),
	latest_operation_time(TEnd),
	T is TEnd - TStart +1,
	prettyprint(T).

% % %

print_action_sequence :-
	complexity_detail(high),
	!,
	report_first_action,
	report_all_actions.
	
print_action_sequence :-
	complexity_detail(medium),
	!,
	report_first_action,
	reportActionNumber,
	report_last_action.

print_action_sequence :-
	complexity_detail(low),
	!,
	prettyprint('The plan had several steps. '),
	report_last_action.

reportActionNumber :-
	prettyprint('This was followed by a sequence of '),
	findall(CA, asp(coarse(CA)), CList),
	findall(FA, asp(fine(FA)), FList),
	length(CList, C),
	length(FList, F),
	printActionNumberSpecific(C, F).

printActionNumberSpecific(C, _) :-
	representation_granularity(coarse),
	prettyprint(C),
	prettyprint(' coarse actions. ').
printActionNumberSpecific(C, F) :-
	(representation_granularity(moderate) ; representation_granularity(fine)),
	prettyprint(C),
	prettyprint(' coarse actions comprising '),
	prettyprint(F),
	prettyprint(' fine actions. ').
	
% % %

report_all_actions :-
	representation_granularity(fine),
	!,
	findall([ActualAct,T], ( asp(fine(hpd(ActualAct,T))), not(reported(hpd(ActualAct,T))) ), FineActsList),
	sort(FineActsList, List),
	recursive_describe_action_fine(List).
report_all_actions :-
	(representation_granularity(coarse) ; representation_granularity(moderate)),
	asp(coarse(Action)),
	not(reported(Action)),
	!,
	Action = hpd(ActualAct,T),
	not(( asp(coarse(hpd(A2,T2))), T2 < T, not(reported(hpd(A2,T2))) )),
	describe_action(coarse(ActualAct), T),
	assert(reported(Action)),
	!,
	report_all_actions.
report_all_actions.

recursive_describe_action_fine([]) :- !.
recursive_describe_action_fine([A|B]) :-
	A = [ActualAct,T],
	describe_action(fine(ActualAct), T),
	assert(reported(hpd(ActualAct,T))),
	!,
	recursive_describe_action_fine(B).

report_first_action :-
	representation_granularity(fine),
	!,
	asp(fine(Action)),
	Action = hpd(ActualAction,T),
	not(( asp(fine(hpd(_,T2))), T2 < T )),
	describe_action_with(fine(ActualAction), T, 'Initially, '),
	assert(reported(Action)),
	!.
report_first_action :-
	% Implied: (representation_granularity(coarse) ; representation_granularity(moderate)),
	asp(coarse(Action)),
	Action = hpd(ActualAction,T),
	not(( asp(coarse(hpd(_,T2))), T2 < T )),
	describe_action_with(coarse(ActualAction), T, 'Initially, '),
	assert(reported(Action)),
	!.
	
report_last_action :-
	representation_granularity(fine),
	!,
	asp(fine(Action)),
	Action = hpd(ActualAction,T),
	not(( asp(fine(hpd(_,T2))), T2 > T )),
	describe_action_with(fine(ActualAction), T, 'In the final action, '),
	assert(reported(Action)),
	!.
report_last_action :-
	% Implied: (representation_granularity(coarse) ; representation_granularity(moderate)),
	asp(coarse(Action)),
	Action = hpd(ActualAction,T),
	not(( asp(coarse(hpd(_,T2))), T2 > T )),
	describe_action_with(coarse(ActualAction), T, 'In the final action, '),
	assert(reported(Action)),
	!.

describe_action(A, T) :-
	join_word(J),
	describe_action_with(A, T, J),
	change_join_word(J).

join_word('Next, ').

change_join_word('Next, ') :-
	retractall(join_word(_)),
	asserta(join_word('Then, ')).
change_join_word('Then, ') :-
	retractall(join_word(_)),
	asserta(join_word('After this, ')).
change_join_word('After this, ') :-
	retractall(join_word(_)),
	asserta(join_word('Next, ')).

%%% Functions for giving a description of one action

describe_action_with(Action, T, Prefix) :-
	prettyprint(Prefix),
	(Action = coarse(ActionTerm) ; Action = fine(ActionTerm)),
	use_grammar_rule(ActionTerm),
	describe_outcomes(Action, T),
	prettyprintln('').

use_grammar_rule(ActionTerm) :-
	% Sentence template: "[actor] [verb past tense] [object1] {to [object2]} {by [object3]} {with [object4]} {and [object5]}"
	functor(ActionTerm, ActionName, _Arity),
	action_syntax(ActionName, VerbPastTense, TypeList),
	getCorrectArg(actor, ActionTerm, TypeList, ActorValue),
	print_obj(ActorValue), % '[actor]'
	prettyprint(' '),
	prettyprint(VerbPastTense), % '[verb past tense]'
	(getCorrectArg(object1, ActionTerm, TypeList, O1Value) -> (prettyprint(' '), print_obj(O1Value)) ; true), % '[object1]'
	(getCorrectArg(object2, ActionTerm, TypeList, O2Value) -> (prettyprint(' to '), print_obj(O2Value)) ; true), % 'to [object2]'
	(getCorrectArg(object3, ActionTerm, TypeList, O3Value) -> (prettyprint(' by '), print_obj(O3Value)) ; true), % 'by [object3]'
	(getCorrectArg(object4, ActionTerm, TypeList, O4Value) -> (prettyprint(' with '), print_obj(O4Value)) ; true), % 'with [object4]'
	(getCorrectArg(object5, ActionTerm, TypeList, O5Value) -> (prettyprint(' and '), print_obj(O5Value)) ; true), % 'and [object5]'
	prettyprint('. ').

getCorrectArg(Symbol, Term, TypeList, Value) :-
	nth1(Index, TypeList, Symbol),
	arg(Index, Term, Value),
	!.

% % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % %

% Descriptor function
% FIRST VARIATION: Coarse representation granularity + medium outcome detail.
% 1. If there is another coarse action after this, say the coarse action enabled it.
% 2. Else if the overall goal is achieved, say the coarse action achieved it.
% 3. Else say the coarse action produced a failure state.
describe_outcomes(coarse(Action), Time) :-
	complexity_detail(medium),
	!,
	get_nonrefined_end_time(Action, Time, EndTime),
	describe_outcomes_coarse_continue('This action ', Time, EndTime).

% Descriptor function
% SECOND VARIATION: Coarse representation granularity + high outcome detail.	
% 1. State nonrefined fluent outcomes of coarse action.
% 2. If there is another coarse action after this, say the outcomes enabled it.
% 3. Else if the overall goal is achieved, say the outcomes achieved it.
% 4. Else say the outcomes produced a failure state.
describe_outcomes(coarse(Action), Time) :-
	complexity_detail(high),
	communication_specificity(1),
	!,
	get_nonrefined_end_time(Action, Time, EndTime),
	prettyprint('This resulted in '),
	count_nonrefined_fluent_outcomes(Time, EndTime, Count),
	print_effect_count(Count),
	describe_outcomes_coarse_continue('These effects ', Time, EndTime).
describe_outcomes(coarse(Action), Time) :-
	complexity_detail(high),
	get_nonrefined_end_time(Action, Time, EndTime),
	count_nonrefined_fluent_outcomes(Time, EndTime, 0), % No discernible effects
	!,
	prettyprint('This resulted in no discernible effects. '),
	describe_outcomes_coarse_continue('However, this ', Time, EndTime).
describe_outcomes(coarse(Action), Time) :-
	complexity_detail(high),
	!,
	get_nonrefined_end_time(Action, Time, EndTime),
	prettyprint('This resulted in effects: '),
	print_nonrefined_fluent_outcomes(Time, EndTime),
	describe_outcomes_coarse_continue('These effects ', Time, EndTime).

describe_outcomes_coarse_continue(Prefix, _Time, EndTime) :-
	T2 is EndTime +1,
	asp(coarse(hpd(_,T2))),
	prettyprint(Prefix),
	prettyprint('enabled the next action. '),
	!.
describe_outcomes_coarse_continue(Prefix, _Time, _EndTime) :-
	goal_was_achieved,
	prettyprint(Prefix),
	prettyprint('achieved the overall goal. '),
	!.
describe_outcomes_coarse_continue(Prefix, _Time, _EndTime) :-
	prettyprint(Prefix),
	prettyprint('resulted in a failure state. '),
	!.

print_effect_count(0) :-
	prettyprint(' no effects! ').
print_effect_count(1) :-
	prettyprint(' some effect. ').
print_effect_count(Count) :-
	prettyprint(Count),
	prettyprint(' effects. ').

%%%%%%%%%%%%%%%%%%%%%%

% Coarse action occurred "at" T, i.e., that was the start time.
% Find the end time T2 from the final related fine action (+1).
get_nonrefined_end_time(Action, T, T2) :-
	link(FineActionList, Action, T),
	last(FineActionList, T2),
	!.
	
print_nonrefined_fluent_outcomes(T, TFinal) :-
	T2 is TFinal +1,
	% Find all coarse fluents whose truth value reversed between timesteps T and T2.
	% (for now, find all fluents, regardless of representation_granularity - TODO, extend...
	%  note no assumption domain distinguishes between specifically coarse and fine fluents in machine-readable way)
	% Recursively print this list with '; ' appended, finishing in '. '
	findall(not(X), (asp(holds(X, T)), not_holds_either_way(X, T2)), ChangeList1),
	findall(X, (asp(holds(X, T2)), not_holds_either_way(X, T)), ChangeList2),
	append(ChangeList1, ChangeList2, ChangeList),
	print_recursive_changelist(ChangeList).

count_nonrefined_fluent_outcomes(T, TFinal, Length) :-
	T2 is TFinal +1,
	findall(not(X), (asp(holds(X, T)), not_holds_either_way(X, T2)), ChangeList1),
	findall(X, (asp(holds(X, T2)), not_holds_either_way(X, T)), ChangeList2),
	append(ChangeList1, ChangeList2, ChangeList),
	length(ChangeList, Length).
	
print_recursive_changelist([A]) :-
	!,
	prettyprint(A),
	prettyprint('. ').
print_recursive_changelist([A|B]) :-
	prettyprint(A),
	prettyprint('; '),
	print_recursive_changelist(B).

not_holds_either_way(X, T) :-
	not(asp(holds(X, T))),
	!.
not_holds_either_way(X, T) :-
	asp(not_holds(X, T)),
	!.

%%%%%%%%%%%%%%%%%%%%%%

% Descriptor function
% THIRD VARIATION: Fine representation granularity + medium outcome detail.
% 1. Only if the fine action is the final in a coarse action X, call functions to describe X.
% 2. Then say the fine action achieved it.
% 3. If there is another coarse action after X, say X enabled it.
% 4. Else if the overall goal is achieved, say X achieved it.
% 5. Else say X produced a failure state.
describe_outcomes(fine(_Action), FineTime) :-
	complexity_detail(medium),
	link(FineActionList, CoarseAction, CoarseActionTime),
	last(FineActionList, FineTime),
	!,
	prettyprint('The result was that overall: '),
	use_grammar_rule(CoarseAction),
	describe_outcomes_coarse_continue('This higher level action ', CoarseActionTime, FineTime).

% Descriptor function
% FOURTH VARIATION: Fine representation granularity + high outcome detail.
% 1. State refined fluent outcomes of fine action. i.e. for now, anything that changed on the immediate time step.
% 2. Case 1: It is the end of a coarse action X.
%    a) Call functions to describe X.
%    b) State nonrefined fluent outcomes of X.
%    c) If there is another coarse action after X, say the nonrefined outcomes enabled it.
%    d) Else if the overall goal is achieved, say the nonrefined outcomes achieved it.
%    e) Else say the nonrefined outcomes produced a failure state.
% 3. Case 2: It is not the end of any coarse action.
%    a) If there is a fine action following, say the refined outcomes enabled that next fine action.
%    b) Else if the goal was not achieved, say the refined outcomes produced a failure state immediately.
%    c) Else error.
describe_outcomes(fine(_Action), Time) :-
	complexity_detail(high),
	communication_specificity(1),
	!,
	prettyprint('This resulted in '),
	count_refined_fluent_outcomes(Time, Count),
	print_effect_count(Count),
	describe_fine_extensive(Time).
describe_outcomes(fine(_Action), Time) :-
	complexity_detail(high),
	count_nonrefined_fluent_outcomes(Time, Time, 0), % No discernible effects
	!,
	prettyprint('This resulted in no discernible effects. However... '),
	describe_fine_extensive(Time).
	
describe_outcomes(fine(_Action), Time) :-
	complexity_detail(high),
	!,
	prettyprint('This resulted in effects: '),
	print_refined_fluent_outcomes(Time),
	describe_fine_extensive(Time).

% Descriptor function
% FIFTH VARIATION: low outcome detail...
describe_outcomes(_, _T).

% % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % %

% Descriptor function
% Case 1: It is the end of a coarse action.
describe_fine_extensive(FineTime) :-
	link(FineActionList, CoarseAction, CoarseActionTime),
	last(FineActionList, FineTime),
	!,
	prettyprint('The result was that overall: '),
	use_grammar_rule(CoarseAction),
	prettyprint('This higher level action resulted in total effects: '),
	print_nonrefined_fluent_outcomes(CoarseActionTime, FineTime), % Start, End
	describe_outcomes_coarse_continue('Then this higher level action ', CoarseActionTime, FineTime).

% Descriptor function
% Case 2: It is not the end of any coarse action.
describe_fine_extensive(Time) :-
	describe_outcomes_fine_continue('These effects ', Time).

describe_outcomes_fine_continue(Prefix, Time) :-
	T2 is Time +1,
	asp(fine(hpd(_,T2))),
	prettyprint(Prefix),
	prettyprint('enabled the next fine action. '),
	!.
describe_outcomes_fine_continue(_Prefix, _Time) :-
	goal_was_achieved,
	trace, fail,
	!.
describe_outcomes_fine_continue(Prefix, _Time) :-
	prettyprint(Prefix),
	prettyprint('resulted in an immediate failure state. '),
	!.

print_refined_fluent_outcomes(T) :-
	T2 is T +1,
	% Find all fine fluents whose truth value reversed between T and T2.
	% (note this may match coarse fluents in the case where the fine action ends a coarse action... 
	%  note also no assumption domain distinguishes between specifically coarse and fine fluents in machine-readable way)
	findall(not(X), (asp(holds(X, T)), not_holds_either_way(X, T2)), ChangeList1),
	findall(X, (asp(holds(X, T2)), not_holds_either_way(X, T)), ChangeList2),
	append(ChangeList1, ChangeList2, ChangeList),
	print_recursive_changelist(ChangeList).
count_refined_fluent_outcomes(T, Length) :-
	T2 is T +1,
	findall(not(X), (asp(holds(X, T)), not_holds_either_way(X, T2)), ChangeList1),
	findall(X, (asp(holds(X, T2)), not_holds_either_way(X, T)), ChangeList2),
	append(ChangeList1, ChangeList2, ChangeList),
	length(ChangeList, Length).
	
% % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % %

% For these explanations, can assume the first object to be printed is the agent speaking
% TODO - make this more robust for when this will not be the case
print_obj(DomainSymbol) :-
	use_pov(none),
	!,
	print_obj_method(DomainSymbol).
print_obj(DomainSymbol) :-
	use_pov(DomainSymbol),
	not(self_described),
	!,
	assert(self_described),
	prettyprint('I ('),
	print_obj_method(DomainSymbol),
	prettyprint(')').
print_obj(DomainSymbol) :-
	use_pov(DomainSymbol),
	self_described,
	!,
	prettyprint('I').

print_obj(DomainSymbol) :-
	print_obj_method(DomainSymbol).

% Specificity 1...	
print_obj_method(DomainSymbol) :-
	communication_specificity(1),
	!,
	prettyprint('a '),
	less_specific_sort(DomainSymbol, Sort),
	prettyprint(Sort).
% Specificity 2...
print_obj_method(DomainSymbol) :-
	communication_specificity(2),
	complexity_detail(low),
	!,
	prettyprint('a '),
	specific_sort(DomainSymbol, Sort),
	prettyprint(Sort).
print_obj_method(DomainSymbol) :-
	communication_specificity(2),
	complexity_detail(medium),
	!,
	prettyprint('a'),
	specific_sort(DomainSymbol, Sort),
	print_determining_attributes(Sort, DomainSymbol),
	prettyprint(Sort).
print_obj_method(DomainSymbol) :-
	communication_specificity(2),
	complexity_detail(high),
	!,
	prettyprint('a'),
	specific_sort(DomainSymbol, Sort),
	print_all_attributes(DomainSymbol),
	prettyprint(Sort).
% Specificity 3...
print_obj_method(DomainSymbol) :-
	communication_specificity(3),
	(complexity_detail(low) ; complexity_detail(medium)),
	!,
	prettyprint('the'),
	specific_sort(DomainSymbol, Sort),
	print_determining_attributes(Sort, DomainSymbol),
	prettyprint(Sort).
print_obj_method(DomainSymbol) :-
	communication_specificity(3),
	complexity_detail(high),
	!,
	prettyprint('the'),
	specific_sort(DomainSymbol, Sort),
	print_all_attributes(DomainSymbol),
	prettyprint(Sort).
%% Specificity 4...
print_obj_method(DomainSymbol) :-
	communication_specificity(4),
	complexity_detail(low),
	!,
	prettyprint(DomainSymbol).
print_obj_method(DomainSymbol) :-
	communication_specificity(4),
	complexity_detail(medium),
	!,
	prettyprint('the '),
	specific_sort(DomainSymbol, Sort),
	prettyprint(Sort),
	prettyprint(' "'),
	prettyprint(DomainSymbol),
	prettyprint('"').
print_obj_method(DomainSymbol) :-
	communication_specificity(4),
	complexity_detail(high),
	!,
	prettyprint('the'),
	specific_sort(DomainSymbol, Sort),
	print_all_attributes(DomainSymbol),
	prettyprint(Sort),
	prettyprint(' "'),
	prettyprint(DomainSymbol),
	prettyprint('"').
	
specific_sort(DomainSymbol, Sort) :-
	asp(sorts(Sort, List)),
	member(DomainSymbol, List).
	
less_specific_sort(DomainSymbol, GeneralSort) :-
	asp(sorts(ChildSort, List)),
	member(DomainSymbol, List),
	asp(sort_group(GeneralSort, ChildList)),
	member(ChildSort, ChildList),
	!.
% Default...
less_specific_sort(DomainSymbol, GeneralSort) :-
	specific_sort(DomainSymbol, GeneralSort).

%

domain_symbol_att_values(DomainSymbol, ReturnList) :-
	findall(	Val,
				(   asp(predicate(Term)), functor(Term, _Pred, 2), arg(1, Term, DomainSymbol), arg(2, Term, Val)   ),
				ReturnList).
				
% Print all of the entity or object's attributes.
print_all_attributes(DomainSymbol) :-
	domain_symbol_att_values(DomainSymbol, ValList),
	print_each_element(ValList, " ").

print_each_element([], _) :-
	prettyprint(" ").
print_each_element([Val|Tail], PrefixSpace) :-
	prettyprint(PrefixSpace),
	prettyprint(Val),
	print_each_element(Tail, " ").

% Print a set of attributes that are sufficient for uniqueness.
% Check for uniqueness currently, and if not, add another attribute.
% Catch case where it is impossible to genuinely get uniqueness.
print_determining_attributes(Sort, DomainSymbol) :-
	domain_symbol_att_values(DomainSymbol, ValList),
	CurrentReportableAttList = [],
	continue_until_uniqueness(Sort, DomainSymbol, CurrentReportableAttList, ValList).

continue_until_uniqueness(_Sort, _DomainSymbol, CurrentReportableAttList, []) :-
	!,
	print_each_element(CurrentReportableAttList, " ").
continue_until_uniqueness(Sort, DomainSymbol, CurrentReportableAttList, _ValList) :-
	uniquely_identified(Sort, DomainSymbol, CurrentReportableAttList),
	!,
	print_each_element(CurrentReportableAttList, " ").
continue_until_uniqueness(Sort, DomainSymbol, CurrentReportableAttList, [Val|ValTail]) :-
	append(CurrentReportableAttList, [Val], NewAttList),
	!,
	continue_until_uniqueness(Sort, DomainSymbol, NewAttList, ValTail).

% The highest computational cost of explanation occurs here, due to looped multiple comparisons.
% It only occurs when the system has to find a minimal set of descriptors necessary to uniquely identify an object, as opposed to e.g. finding no or all descriptors.
% It is only costly when there is a large number of objects with the same sort, e.g., 4x10x10=400 different room cells for sample domain #2, so that uniqueness must be checked for a very large number of times.
% If this ever becomes a problem, note that it can be compensated for by arranging the sort hierarchy so that fewer objects appear in the same subsort.
% e.g., for sample domain #2, replace the static attribute indicating column with a cell subsort that groups all cells in the column.
uniquely_identified(Sort, DomainSymbol, CurrentReportableAttList) :-
	asp(sorts(Sort, List)),
	not((
		member(OtherSymbol, List),
		OtherSymbol \= DomainSymbol,
		has_all_att_vals(OtherSymbol, CurrentReportableAttList)
	)).

% When determining uniqueness, this is called multiple times for each object of the same sort.
has_all_att_vals(_OtherSymbol, []).
has_all_att_vals(OtherSymbol, [A|B]) :- 
	asp(predicate(Term)),
	functor(Term, _Pred, 2),
	arg(1, Term, OtherSymbol),
	arg(2, Term, A),
	has_all_att_vals(OtherSymbol, B).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% 6: Test commands %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Test #1: Produce an explanation for each possible combination of axes %%%%%
test :- begin_test.
begin_test :-
	member(Val1, [coarse, moderate, fine]),
	member(Val2, [1, 2, 3, 4]),
	member(Val3, [low, medium, high]),
		set_axis(representation_granularity, Val1), set_axis(communication_specificity, Val2), set_axis(complexity_detail, Val3),
		prettyprint('representation_granularity: '), prettyprintln(Val1), prettyprint('communication_specificity: '), prettyprintln(Val2), prettyprint('complexity_detail: '), prettyprintln(Val3),
		initialise_for_reset, generate_explanation, prettyprintln('\n***************\n'),
	fail.
begin_test :- !.

%%%%% Test #2: Repeatedly produce explanations for a particular combination of axes, and measure time cost %%%%%
% Parameters: output file name, number of trials to perform, position on explanatory axes.
% Example usage: time_tests('out.txt', 10000, fine, 4, high).
time_tests(OutFile, NumberOfRepeats, V1, V2, V3) :-
	open(OutFile, write, O),
	close(O), % Create output file
	prettyprintln('Running time trials...'),
	unload_file('pretty_printer.pl'),
	consult('pretty_printer_suppress.pl'), % Suppress normal explanation output (restores it after tests are complete)
	test_repeat(OutFile, NumberOfRepeats, V1, V2, V3).
test_repeat(_OutFile, 0, _, _, _) :-
	!,
	reset_printer,
	prettyprintln('...Finished.').
test_repeat(OutFile, N, V1, V2, V3) :-
	perform_time_test(OutFile, V1, V2, V3),
	M is N-1,
	test_repeat(OutFile, M, V1, V2, V3).
perform_time_test(F, V1, V2, V3) :-
	testing_output_file(FileName),
	protocol(FileName),
	get_time(Time),
	retractall(test_time_start(_)),
	asserta(test_time_start(Time)),
	begin_test(F, V1, V2, V3).
begin_test(_, Val1, Val2, Val3) :-
	set_axis(representation_granularity, Val1), set_axis(communication_specificity, Val2), set_axis(complexity_detail, Val3),
	prettyprint('representation_granularity: '), prettyprintln(Val1), prettyprint('communication_specificity: '), prettyprintln(Val2), prettyprint('complexity_detail: '), prettyprintln(Val3),
	initialise_for_reset, generate_explanation, prettyprintln('\n***************\n'),
	fail.
begin_test(F, _, _, _) :-
	get_time(End),
	test_time_start(Start),
	noprotocol,
	Diff is End - Start,
	open(F, append, Write),
	write(Write, Diff),
	write(Write, '\n'),
	close(Write).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 7: Startup instructions  %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

beginStartupPrompts :-	
	prettyprintln('\nExplanation system prototype.'),
	giveUserPrompts.

giveUserPrompts :-
	prettyprintln('-----------------------------'),
	prettyprintln('Input "1." to initialise default test domain #1, Robot Assistant.'),
	prettyprintln('Input "2." to initialise default test domain #2, Robot Assistant (fine quantization).'),
	prettyprintln('Input "3." to initialise default test domain #3, Robot Baker.'),
	prettyprintln('Otherwise, input the file name of a custom domain to translate and initialise.'),
	read(TextInput),
	(read_domain_file(TextInput) -> give_recommendations ; (prettyprintln('\n'), giveUserPrompts)).
		
read_domain_file(1) :-
	retractall(domain_file_saved(_)),
	assert(domain_file_saved(example_explanation_domain)),
	consult('example_explanation_domain.pl'),
	prettyprintln('...example_explanation_domain loaded.').
read_domain_file(2) :-
	retractall(domain_file_saved(_)),
	assert(domain_file_saved(example_explanation_domain_finer)),
	consult('example_explanation_domain_finer.pl'),
	prettyprintln('...example_explanation_domain_finer loaded.').
read_domain_file(3) :-
	retractall(domain_file_saved(_)),
	assert(domain_file_saved(example_explanation_domain_cooking)),
	consult('example_explanation_domain_cooking.pl'),
	prettyprintln('...example_explanation_domain_cooking loaded.').
read_domain_file(Other) :-
	retractall(domain_file_saved(_)),
	exists_file(Other),
	assert(domain_file_saved(Other)),
	consult(Other),
	prettyprint('...custom domain '),
	prettyprint(Other),
	prettyprintln(' loaded.').
read_domain_file(_) :-
	prettyprintln('ERROR: Domain file does not exist!\n'),
	fail.

give_recommendations :-
	prettyprintln('\n\n-----------------------------'),
	prettyprintln('Command list:'),
	prettyprintln('-----------------------------'),
	prettyprintln('   test. '),
	prettyprintln('   time_tests(Out, N, V1, V2, V3). '),
	prettyprintln('   control_loop. '),
	prettyprintln('   reset. '),
	prettyprintln('   tone. '),
	prettyprintln('   pov(X). '),
	prettyprintln('-----------------------------'),
	prettyprintln('   "test." generates and presents all explanations for the domain scenario. The command returns one explanation for each possible combination of axes.'),
	prettyprintln('   "time_tests(Out, N, V1, V2, V3)." performs N repeated trials of explanation with axis parameters V1, V2, and V3, outputting the time in seconds for each trial to the text file Out.'),
	prettyprintln('      Example usage:'),
	prettyprintln('      time_tests(\'outfile.txt\', 10000, coarse, 3, medium).'),
	prettyprintln('   "control_loop." allows the user to interact with the simulated agent by asking it for explanations in different ways.'),
	prettyprintln('   "reset." unloads the domain file in preparation to load another.'),
	prettyprintln('   "tone." toggles the explanatory tone from formal to informal or vice versa.'),
	prettyprintln('   "pov(X)." sets the explanation\'s point of view to X\'s, or sets it to \'none\' for third person view. This value defaults to rob1 for example domains.'),
	prettyprintln('-----------------------------\n').

% Restore previously suppressed explanation output	
reset_printer :-
	unload_file('pretty_printer_suppress.pl'),
	consult('pretty_printer.pl').

reset :- reset_system.
reset_system :-
	domain_file_saved(File),
	unload_file(File),
	retractall(domain_file_saved(File)),
	prettyprint('System has been reset; unloaded domain file '),
	prettyprintln(File),
	prettyprintln('\n-----------------------------\n'),
	giveUserPrompts.

tone :-
	use_formal_tone(false),
	retractall(use_formal_tone(false)),
	assert(use_formal_tone(true)),
	prettyprintln('Set tone to formal.'),
	!.
tone :-
	use_formal_tone(true),
	retractall(use_formal_tone(true)),
	assert(use_formal_tone(false)),
	prettyprintln('Set tone to informal.'),
	!.

pov(X) :-
	retractall(use_pov(_)),
	asserta(use_pov(X)),
	prettyprint('Set point of view to '),
	prettyprint(X),
	prettyprintln('.'),
	!.

:- initialization(beginStartupPrompts, program). % Only run after Prolog has finished loading, e.g., following any welcome message.
	