%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Section 1: Parameters %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Includes
:- [pretty_printer].
:- [resources]. % For debugging purposes, can be removed to reduce startup lag associated with WordNet

% Select one domain

:- [example_explanation_domain].
%:- [example_explanation_domain_finer].
%:- [example_explanation_domain_cooking].

:- dynamic inPlanMode/1, learningMode/1, last_transitions_failed/1, currently_believed_to_hold/1, currentTime/1, currentTime_unaltered/1, currentGoal/1, obs/3, hpd/2, 
answer_set_goal/1, expected_effects/3, user_alerted_interruption/0, representation_granularity/1, communication_specificity/1, complexity_detail/1, reported/1, join_word/1,
use_pov/1, self_described/0.

:- discontiguous describe_outcomes/2.

%inPlanMode(true).
os(windows).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Section 2: Control %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

control_loop :-
	read_ASP_program_and_output_to_predicates,
	get_user_explanation_request -> continue_to_explanation ; prettyprintln('No explanation requested.').
	
read_ASP_program_and_output_to_predicates :-
	read_ASP_program_and_translate_to_predicates,
	read_ASP_output_and_translate_to_predicates.

continue_to_explanation :-
	generate_explanation,
	!,
	solicit_user_response.

solicit_user_response :- 
	get_text_feedback(Input),
	process_user_input_text(Input),
	!,
	continue_to_explanation.
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
	% As long as a synonym for 'explain', appears, take the part before that and extract any specificity cue
	partition_input(InputString, Preamble, Tell, _Remainder),
	prettyprint('=> "'),
	prettyprint(Tell),
	prettyprintln('"'),
	change_specificity_from_cues(Preamble).
	
partition_input(InputStringX, Preamble, Tell, Remainder) :-
	string_lower(InputStringX, InputString), % Set all characters to lowercase
	split_string_into_three_at_first_instance_of_some_word(InputString,
			["explain", "analyse", "analyze", "explanation", "describe", "tell", "repeat"], Preamble, Tell, Remainder),
	!.
split_string_into_three_at_first_instance_of_some_word(Input, WordList, Output1, Output2, Output3) :-
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
	establish_cues(Text, AxisOrGeneral, Direction), % decrease_specificity/increase_specificity/standard_specificity
	prettyprint('Axis of specificity indicated by user input: '),
	prettyprintln(AxisOrGeneral),
	prettyprint('Direction of specificity indicated by user input: '),
	prettyprintln(Direction),
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
	prettyprintln('(Increase or decrease in specificity ambiguous; defaulting)'),
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
	asp(fine(Action)),
	not(reported(Action)),
	!,
	Action = hpd(ActualAction,T),
	not(( asp(fine(hpd(A2,T2))), T2 < T, not(reported(hpd(A2,T2))) )),
	describe_action(fine(ActualAction), T),
	assert(reported(Action)),
	!,
	report_all_actions.
report_all_actions :-
	(representation_granularity(coarse) ; representation_granularity(moderate)),
	asp(coarse(Action)),
	not(reported(Action)),
	!,
	Action = hpd(ActualAction,T),
	not(( asp(coarse(hpd(A2,T2))), T2 < T, not(reported(hpd(A2,T2))) )),
	describe_action(coarse(ActualAction), T),
	assert(reported(Action)),
	!,
	report_all_actions.
report_all_actions.

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
	% (representation_granularity(coarse) ; representation_granularity(moderate)),
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
	% (representation_granularity(coarse) ; representation_granularity(moderate)),
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
	employ_grammar_rule(ActionTerm),
	describe_outcomes(Action, T),
	prettyprintln('').

employ_grammar_rule(ActionTerm) :-
	% "[actor] [verb past tense] [object1] {to [object2]} {by [object3]} {with [object4]} {and [object5]}"
	functor(ActionTerm, ActionName, _Arity),
	action_syntax(ActionName, VerbPastTense, TypeList),
	% nth1(Index, TypeList, TargetElement)
	getCorrectArg(actor, ActionTerm, TypeList, ActorValue),
	print_obj(ActorValue),
	% '[actor]'
	prettyprint(' '),
	prettyprint(VerbPastTense),
	% '[verb past tense]'
	(getCorrectArg(object1, ActionTerm, TypeList, O1Value) -> prettyprint(' '), print_obj(O1Value) ; true), % '[object1]'
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
	% Find all coarse fluents whose truth value reversed between T and T2.
	% (for now, find all fluents, regardless of representation_granularity - TODO, extend)
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
	employ_grammar_rule(CoarseAction),
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
	employ_grammar_rule(CoarseAction),
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

print_obj(DomainSymbol) :- print_obj_method(DomainSymbol).

print_obj_method(DomainSymbol) :-
	communication_specificity(1),
	!,
	prettyprint('a '),
	less_specific_sort(DomainSymbol, Sort),
	prettyprint(Sort).
%
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
%
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
	print_all_attributes(Sort),
	prettyprint(Sort).
%

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
	print_determining_attributes(Sort, DomainSymbol),
	prettyprint(Sort),
	prettyprint(' "'),
	prettyprint(DomainSymbol),
	prettyprint('"').

%	
	
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
				
% Print all the entity's/object's attributes.
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
% Catch case where it's impossible to genuinely get uniqueness.
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

uniquely_identified(Sort, DomainSymbol, CurrentReportableAttList) :-
	not((
		asp(sorts(Sort, List)),
		member(OtherSymbol, List),
		has_all_att_vals(OtherSymbol, CurrentReportableAttList),
		OtherSymbol \= DomainSymbol
	)).

has_all_att_vals(_Symbol, []).
has_all_att_vals(Symbol, [A|B]) :- 
	asp(predicate(Term)),
	functor(Term, _Pred, 2),
	arg(1, Term, Symbol),
	arg(2, Term, A),
	has_all_att_vals(Symbol, B).
