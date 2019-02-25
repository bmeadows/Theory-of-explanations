
:- discontiguous asp/1.

testing_output_file('explanation_test1_output_fine.txt').

% action_syntax(ActionName, PastTense, [List]) gives syntactic information for each action, to fit into the grammar rule
% => "[actor] [verb past tense] [object1] {to [object2]} {by [object3]} {with [object4]} {and [object5]}"
% e.g. action_syntax(serve, served, [actor, object1, object2])
% e.g. action_syntax(move, moved, [actor, object2])
% e.g. action_syntax(sweep, swept, [actor, object1, object4])

% asp(coarse(hpd(_,T))) states that a coarse action occurred at time T
% e.g. asp(coarse(hpd(serve(rob1,cup1,p1),10)))

% asp(fine(hpd(_,T))) states that a fine action occurred at time T
% e.g. asp(fine(hpd(serve*(rob1,cup1-handle,p1-hand),12)))

% link([List], A, T) associates sequences of fine actions with a single coarse action occurring at T
% e.g. link([9, 10, 11, 12], serve(rob1,cup1,p1), 9)

% plan([List]) lists the (unique) times for coarse actions
% e.g. plan([1, 10, 17])

% asp(goal(T)) is the ASP term stating the time step at which the goal was achieved
% e.g. asp(goal(20))

% asp_goal_string(S) is a string containing the original goal
% e.g. asp_goal_string("goal(I) :- holds(in_hand(P,book1),I), #person(P).").

% Sort hierarchy:
% asp(sorts(Sort, List))
% e.g. asp(sorts(location, [rmwor, rmoff, rmlib])).
% asp(sort_group(ParentSort, ChildList))
% e.g. asp(sort_group(entity, [robot, person])).
% e.g. asp(sort_group(thing, [object, entity])).

% Static attributes:
% asp(predicate(Term))
% e.g. asp(predicate(has_role(p1, engineer))).


% Initial syntactic information / grammar rules:
%
action_syntax(move, 'moved', [actor, object2]).
action_syntax(serve, 'served', [actor, object1, object2]).
action_syntax(putdown, 'put down', [actor, object1]).
action_syntax(pickup, 'picked up', [actor, object1]).
%
action_syntax(move_fine, 'moved', [actor, object2]).
action_syntax(serve_extend, 'offered', [actor, object4, object1, object2, object3]).
action_syntax(serve_release, 'served', [actor, object4, object1, object2, object3]).
action_syntax(serve_retract, 'retracted', [actor, object1]).
action_syntax(putdown_extend, 'put down', [actor, object4, object1, object3]).
action_syntax(putdown_release, 'released', [actor, object4, object1, object3]).
action_syntax(putdown_retract, 'raised', [actor, object1]).
action_syntax(pickup_extend, 'reached for', [actor, object4, object1, object3]).
action_syntax(pickup_grasp, 'grasped', [actor, object4, object1, object3]).
action_syntax(pickup_retract, 'raised', [actor, object1]).
% Comment out for third-person reporting.
use_pov(rob1).

/*    Domain description:
study1, office1, workshop1, kitchen1 each comprised of 10x10 (100) cells. s_5_2 is the cell in the 5th column of the 2nd row in the study1, etc.
Objects: manual1, book1, book2.
Entities: rob1, p1, p2.
Fine arm position, extended/retracted.
Serve involves three fine actions: retracted->extended->grasped->retracted
Putdown involves three fine actions: retracted->extended->given->retracted
Pickup involves three fine actions: retracted->extended->grasped->retracted
Summary: Robot rob1 starts in w_3_5 holding manual1, traverses to s_8_8 to pick up book2, traverses to o_9_5 to serve book2 to p1.

+----------+ +----------+
|1234567890| |1234567890|
|2         | |2         |
|3         | |3         |
|4         | |4         |
|5         | |5         |
|6 study1   | |6  office1 |
|7         | |7         |
|8         | |8         |
|9         D D9         |
|0         D D0         |
+--------DD+ +DD--------+

+--------DD+ +DD--------+
|1234567890D D1234567890|
|2         D D2         |
|3         | |3         |
|4         | |4         |
|5         | |5         |
|6  wshop  | |6 kitchen1 |
|7         | |7         |
|8         | |8         |
|9         | |9         |
|0         | |0         |
+----------+ +----------+
*/

% Robot rob1 starts in w_3_5 holding manual1, traverses to s_8_8 to pick up book2, traverses to o_9_5 to serve book2 to p1.

% Initial ASP terms:
%
asp(coarse(hpd(move(rob1,study1),1))).
  asp(fine(hpd(move_fine(rob1,w_3_5,w_3_4),1))).
  asp(fine(hpd(move_fine(rob1,w_3_4,w_4_4),2))).
  asp(fine(hpd(move_fine(rob1,w_4_4,w_4_3),3))).
  asp(fine(hpd(move_fine(rob1,w_4_3,w_5_3),4))).
  asp(fine(hpd(move_fine(rob1,w_5_3,w_5_2),5))).
  asp(fine(hpd(move_fine(rob1,w_5_2,w_6_2),6))).
  asp(fine(hpd(move_fine(rob1,w_6_2,w_6_1),7))).
  asp(fine(hpd(move_fine(rob1,w_6_1,w_7_1),8))).
  asp(fine(hpd(move_fine(rob1,w_7_1,w_8_1),9))).
  asp(fine(hpd(move_fine(rob1,w_8_1,w_9_1),10))).
  asp(fine(hpd(move_fine(rob1,w_9_1,s_9_0),11))).
  asp(fine(hpd(move_fine(rob1,s_9_0,s_8_0),12))).
  asp(fine(hpd(move_fine(rob1,s_8_0,s_8_9),13))).
  asp(fine(hpd(move_fine(rob1,s_8_9,s_8_8),14))).
asp(coarse(hpd(putdown(rob1,manual1),15))).
  asp(fine(hpd(putdown_extend(rob1,rob1_hand,manual1,manual1_cover),15))).
  asp(fine(hpd(putdown_release(rob1,rob1_hand,manual1,manual1_cover),16))).
  asp(fine(hpd(putdown_retract(rob1,rob1_hand),17))).
asp(coarse(hpd(pickup(rob1,book2),18))).
  asp(fine(hpd(pickup_extend(rob1,rob1_hand,book2,book2_spine),18))).
  asp(fine(hpd(pickup_grasp(rob1,rob1_hand,book2,book2_spine),19))).
  asp(fine(hpd(pickup_retract(rob1,rob1_hand),20))).
asp(coarse(hpd(move(rob1,office1),21))).
  asp(fine(hpd(move_fine(rob1,s_8_8,s_9_8),21))).
  asp(fine(hpd(move_fine(rob1,s_9_8,s_9_9),22))).
  asp(fine(hpd(move_fine(rob1,s_9_9,s_0_9),23))).
  asp(fine(hpd(move_fine(rob1,s_0_9,o_1_9),24))).
  asp(fine(hpd(move_fine(rob1,o_1_9,o_2_9),25))).
  asp(fine(hpd(move_fine(rob1,o_2_9,o_3_9),26))).
  asp(fine(hpd(move_fine(rob1,o_3_9,o_3_8),27))).
  asp(fine(hpd(move_fine(rob1,o_3_8,o_4_8),28))).
  asp(fine(hpd(move_fine(rob1,o_4_8,o_5_8),29))).
  asp(fine(hpd(move_fine(rob1,o_5_8,o_6_8),30))).
  asp(fine(hpd(move_fine(rob1,o_6_8,o_6_7),31))).
  asp(fine(hpd(move_fine(rob1,o_6_7,o_7_7),32))).
  asp(fine(hpd(move_fine(rob1,o_7_7,o_8_7),33))).
  asp(fine(hpd(move_fine(rob1,o_8_7,o_9_7),34))).
  asp(fine(hpd(move_fine(rob1,o_9_7,o_9_6),35))).
  asp(fine(hpd(move_fine(rob1,o_9_6,o_9_5),36))).
asp(coarse(hpd(serve(rob1,book2,p1),37))).
  asp(fine(hpd(serve_extend(rob1,rob1_hand,book2,p1,book2_spine),37))).
  asp(fine(hpd(serve_release(rob1,rob1_hand,book2,p1,book2_spine),38))).
  asp(fine(hpd(serve_retract(rob1,rob1_hand),39))).

link([1,2,3,4,5,6,7,8,9,10,11,12,13,14], move(rob1,study1), 1).
link([15,16,17], putdown(rob1,manual1), 15).
link([18,19,20], pickup(rob1,book2), 18).
link([21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36], move(rob1,office1), 21).
link([37,38,39], serve(rob1,book2,p1), 37).
plan([1, 15, 18, 21, 37]).
asp(goal(40)).
asp_goal_string("goal(I) :- holds(in_hand(p1,book2),I).").
%
asp(sort_group(thing, [place, entity, object])).
asp(sort_group(place, [room, hall])).
asp(sort_group(entity, [robot, person])).
asp(sort_group(object, [cup, book, parcel])).
asp(sorts(room, [study1, office1, workshop1, kitchen1])).
asp(sorts(robot, [rob1])).
asp(sorts(person, [p1, p2])).
asp(sorts(book, [manual1, book1, book2])).
asp(sorts(cup, [cup1])).
asp(sorts(parcel, [parcel1])).
%
asp(sort_group(thing_fine, [place_fine, entity_fine, object_fine])).
asp(sort_group(place_fine, [cell])).
asp(sort_group(entity_fine, [robot_part, person_part])).
asp(sort_group(object_fine, [cup_fine, spine, cover, parcel_fine])).
asp(sorts(cell, [
k_1_1,k_2_1,k_3_1,k_4_1,k_5_1,k_6_1,k_7_1,k_8_1,k_9_1,k_0_1,s_1_1,s_2_1,s_3_1,s_4_1,s_5_1,s_6_1,s_7_1,s_8_1,s_9_1,s_0_1,w_1_1,w_2_1,w_3_1,w_4_1,w_5_1,w_6_1,w_7_1,w_8_1,w_9_1,w_0_1,o_1_1,o_2_1,o_3_1,o_4_1,o_5_1,o_6_1,o_7_1,o_8_1,o_9_1,o_0_1,
k_1_2,k_2_2,k_3_2,k_4_2,k_5_2,k_6_2,k_7_2,k_8_2,k_9_2,k_0_2,s_1_2,s_2_2,s_3_2,s_4_2,s_5_2,s_6_2,s_7_2,s_8_2,s_9_2,s_0_2,w_1_2,w_2_2,w_3_2,w_4_2,w_5_2,w_6_2,w_7_2,w_8_2,w_9_2,w_0_2,o_1_2,o_2_2,o_3_2,o_4_2,o_5_2,o_6_2,o_7_2,o_8_2,o_9_2,o_0_2,
k_1_3,k_2_3,k_3_3,k_4_3,k_5_3,k_6_3,k_7_3,k_8_3,k_9_3,k_0_3,s_1_3,s_2_3,s_3_3,s_4_3,s_5_3,s_6_3,s_7_3,s_8_3,s_9_3,s_0_3,w_1_3,w_2_3,w_3_3,w_4_3,w_5_3,w_6_3,w_7_3,w_8_3,w_9_3,w_0_3,o_1_3,o_2_3,o_3_3,o_4_3,o_5_3,o_6_3,o_7_3,o_8_3,o_9_3,o_0_3,
k_1_4,k_2_4,k_3_4,k_4_4,k_5_4,k_6_4,k_7_4,k_8_4,k_9_4,k_0_4,s_1_4,s_2_4,s_3_4,s_4_4,s_5_4,s_6_4,s_7_4,s_8_4,s_9_4,s_0_4,w_1_4,w_2_4,w_3_4,w_4_4,w_5_4,w_6_4,w_7_4,w_8_4,w_9_4,w_0_4,o_1_4,o_2_4,o_3_4,o_4_4,o_5_4,o_6_4,o_7_4,o_8_4,o_9_4,o_0_4,
k_1_5,k_2_5,k_3_5,k_4_5,k_5_5,k_6_5,k_7_5,k_8_5,k_9_5,k_0_5,s_1_5,s_2_5,s_3_5,s_4_5,s_5_5,s_6_5,s_7_5,s_8_5,s_9_5,s_0_5,w_1_5,w_2_5,w_3_5,w_4_5,w_5_5,w_6_5,w_7_5,w_8_5,w_9_5,w_0_5,o_1_5,o_2_5,o_3_5,o_4_5,o_5_5,o_6_5,o_7_5,o_8_5,o_9_5,o_0_5,
k_1_6,k_2_6,k_3_6,k_4_6,k_5_6,k_6_6,k_7_6,k_8_6,k_9_6,k_0_6,s_1_6,s_2_6,s_3_6,s_4_6,s_5_6,s_6_6,s_7_6,s_8_6,s_9_6,s_0_6,w_1_6,w_2_6,w_3_6,w_4_6,w_5_6,w_6_6,w_7_6,w_8_6,w_9_6,w_0_6,o_1_6,o_2_6,o_3_6,o_4_6,o_5_6,o_6_6,o_7_6,o_8_6,o_9_6,o_0_6,
k_1_7,k_2_7,k_3_7,k_4_7,k_5_7,k_6_7,k_7_7,k_8_7,k_9_7,k_0_7,s_1_7,s_2_7,s_3_7,s_4_7,s_5_7,s_6_7,s_7_7,s_8_7,s_9_7,s_0_7,w_1_7,w_2_7,w_3_7,w_4_7,w_5_7,w_6_7,w_7_7,w_8_7,w_9_7,w_0_7,o_1_7,o_2_7,o_3_7,o_4_7,o_5_7,o_6_7,o_7_7,o_8_7,o_9_7,o_0_7,
k_1_8,k_2_8,k_3_8,k_4_8,k_5_8,k_6_8,k_7_8,k_8_8,k_9_8,k_0_8,s_1_8,s_2_8,s_3_8,s_4_8,s_5_8,s_6_8,s_7_8,s_8_8,s_9_8,s_0_8,w_1_8,w_2_8,w_3_8,w_4_8,w_5_8,w_6_8,w_7_8,w_8_8,w_9_8,w_0_8,o_1_8,o_2_8,o_3_8,o_4_8,o_5_8,o_6_8,o_7_8,o_8_8,o_9_8,o_0_8,
k_1_9,k_2_9,k_3_9,k_4_9,k_5_9,k_6_9,k_7_9,k_8_9,k_9_9,k_0_9,s_1_9,s_2_9,s_3_9,s_4_9,s_5_9,s_6_9,s_7_9,s_8_9,s_9_9,s_0_9,w_1_9,w_2_9,w_3_9,w_4_9,w_5_9,w_6_9,w_7_9,w_8_9,w_9_9,w_0_9,o_1_9,o_2_9,o_3_9,o_4_9,o_5_9,o_6_9,o_7_9,o_8_9,o_9_9,o_0_9,
k_1_0,k_2_0,k_3_0,k_4_0,k_5_0,k_6_0,k_7_0,k_8_0,k_9_0,k_0_0,s_1_0,s_2_0,s_3_0,s_4_0,s_5_0,s_6_0,s_7_0,s_8_0,s_9_0,s_0_0,w_1_0,w_2_0,w_3_0,w_4_0,w_5_0,w_6_0,w_7_0,w_8_0,w_9_0,w_0_0,o_1_0,o_2_0,o_3_0,o_4_0,o_5_0,o_6_0,o_7_0,o_8_0,o_9_0,o_0_0
])).
asp(sorts(robot_part, [rob1_hand, rob1_centre, rob1_wheel1, rob1_wheel2])).
asp(sorts(person_part, [p1_head, p1_hand, p2_head, p2_hand])).
asp(sorts(spine, [manual1_spine, book1_spine, book2_spine])).
asp(sorts(cover, [manual1_cover, book1_cover, book2_cover])).
%
asp(predicate(size(manual1, small))).
asp(predicate(size(book1, medium))).
asp(predicate(size(book2, large))).
asp(predicate(locomotion(rob1, wheeled))).
asp(predicate(role(rob1, delivery))).
asp(predicate(role(p1, sales))).
asp(predicate(role(p2, management))).
asp(predicate(size(study1, medium))).
asp(predicate(size(office1, medium))).
asp(predicate(size(kitchen1, small))).
asp(predicate(size(workshop1, small))).
asp(predicate(purpose(study1, study))).
asp(predicate(purpose(office1, office))).
asp(predicate(purpose(kitchen1, kitchen))).
asp(predicate(purpose(workshop1, workshop))).
%
asp(predicate(x(N, 'x=1'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'1',_,_]).
asp(predicate(x(N, 'x=2'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'2',_,_]).
asp(predicate(x(N, 'x=3'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'3',_,_]).
asp(predicate(x(N, 'x=4'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'4',_,_]).
asp(predicate(x(N, 'x=5'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'5',_,_]).
asp(predicate(x(N, 'x=6'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'6',_,_]).
asp(predicate(x(N, 'x=7'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'7',_,_]).
asp(predicate(x(N, 'x=8'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'8',_,_]).
asp(predicate(x(N, 'x=9'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'9',_,_]).
asp(predicate(x(N, 'x=10'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,'0',_,_]).
asp(predicate(y(N, 'y=1'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'1']).
asp(predicate(y(N, 'y=2'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'2']).
asp(predicate(y(N, 'y=3'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'3']).
asp(predicate(y(N, 'y=4'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'4']).
asp(predicate(y(N, 'y=5'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'5']).
asp(predicate(y(N, 'y=6'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'6']).
asp(predicate(y(N, 'y=7'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'7']).
asp(predicate(y(N, 'y=8'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'8']).
asp(predicate(y(N, 'y=9'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'9']).
asp(predicate(y(N, 'y=10'))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [_,_,_,_,'0']).
%
asp(predicate(purpose(N, study))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [s,_,_,_,_]).
asp(predicate(purpose(N, office))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [o,_,_,_,_]).
asp(predicate(purpose(N, kitchen))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [k,_,_,_,_]).
asp(predicate(purpose(N, workshop))) :- asp(sorts(cell, Cells)), member(N, Cells), atom_chars(N, [w,_,_,_,_]).
% rob1_hand
% rob1_wheel1
% rob1_wheel2
asp(predicate(position(rob1_hand, front))).
asp(predicate(position(rob1_wheel1, left))).
asp(predicate(position(rob1_wheel2, right))).
asp(predicate(type(manual1_cover, hard))).
asp(predicate(type(book1_cover, soft))).
asp(predicate(type(book2_cover, hard))).
% manual1_spine
% book1_spine
% book2_spine
asp(predicate(type(manual1_spine, regular))).
asp(predicate(type(book1_spine, regular))).
asp(predicate(type(book2_spine, regular))).

% History of observations
asp(holds(loc(p1, office1), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
asp(holds(loc_fine(p1, o_9_5), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
asp(holds(loc(p2, kitchen1), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
asp(holds(loc_fine(p2, k_7_9), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
%
asp(holds(loc(rob1, workshop1), T)) :- member(T,[1,2,3,4,5,6,7,8,9,10,11]).
asp(holds(loc(manual1, workshop1), T)) :- member(T,[1,2,3,4,5,6,7,8,9,10,11]).
asp(holds(loc(rob1, study1), T)) :- member(T,[12,13,14,15,16,17,18,19,20,21,22,23,24]).
asp(holds(loc(manual1, study1), T)) :- member(T,[12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
asp(holds(loc(rob1, office1), T)) :- member(T,[25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
asp(holds(loc(book2, study1), T)) :- member(T,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]).
asp(holds(loc(book2, office1), T)) :- member(T,[25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
%
asp(holds(loc(book1, study1), T)) :- member(T, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
asp(holds(loc_fine(book1, s_4_2), T)) :- member(T, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]).
%
asp(holds(in_hand(rob1, manual1), T)) :- member(T,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]).
  asp(holds(in_hand_fine(rob1, rob1_hand, manual1, manual1_cover), T)) :- member(T,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]).
asp(holds(in_hand(rob1, book2), T)) :- member(T,[20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38]).
  asp(holds(in_hand_fine(rob1, rob1_hand, book2, book2_spine), T)) :- member(T,[20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38]).
asp(holds(in_hand(p1, book2), T)) :- member(T,[39,40]).
  asp(holds(in_hand_fine(p1, p1_hand, book2, book2_spine), T)) :- member(T,[39,40]).
%
asp(holds(arm_position(rob1, retracted), T)) :- member(T,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]).
asp(holds(arm_position(rob1, extended), T)) :- member(T,[16,17]).
asp(holds(arm_position(rob1, retracted), T)) :- member(T,[18]).
asp(holds(arm_position(rob1, extended), T)) :- member(T,[19,20]).
asp(holds(arm_position(rob1, retracted), T)) :- member(T,[21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37]).
asp(holds(arm_position(rob1, extended), T)) :- member(T,[38,39]).
asp(holds(arm_position(rob1, retracted), T)) :- member(T,[40]).
%
asp(holds(loc_fine(rob1, w_3_5), 1)). asp(holds(loc_fine(manual1, w_3_5), 1)). asp(holds(loc_fine(book2, s_8_8), 1)).
asp(holds(loc_fine(rob1, w_3_4), 2)). asp(holds(loc_fine(manual1, w_3_4), 2)). asp(holds(loc_fine(book2, s_8_8), 2)).
asp(holds(loc_fine(rob1, w_4_4), 3)). asp(holds(loc_fine(manual1, w_4_4), 3)). asp(holds(loc_fine(book2, s_8_8), 3)).
asp(holds(loc_fine(rob1, w_4_3), 4)). asp(holds(loc_fine(manual1, w_4_3), 4)). asp(holds(loc_fine(book2, s_8_8), 4)).
asp(holds(loc_fine(rob1, w_5_3), 5)). asp(holds(loc_fine(manual1, w_5_3), 5)). asp(holds(loc_fine(book2, s_8_8), 5)).
asp(holds(loc_fine(rob1, w_5_2), 6)). asp(holds(loc_fine(manual1, w_5_2), 6)). asp(holds(loc_fine(book2, s_8_8), 6)).
asp(holds(loc_fine(rob1, w_6_2), 7)). asp(holds(loc_fine(manual1, w_6_2), 7)). asp(holds(loc_fine(book2, s_8_8), 7)).
asp(holds(loc_fine(rob1, w_6_1), 8)). asp(holds(loc_fine(manual1, w_6_1), 8)). asp(holds(loc_fine(book2, s_8_8), 8)).
asp(holds(loc_fine(rob1, w_7_1), 9)). asp(holds(loc_fine(manual1, w_7_1), 9)). asp(holds(loc_fine(book2, s_8_8), 9)).
asp(holds(loc_fine(rob1, w_8_1), 10)). asp(holds(loc_fine(manual1, w_8_1), 10)). asp(holds(loc_fine(book2, s_8_8), 10)).
asp(holds(loc_fine(rob1, w_9_1), 11)). asp(holds(loc_fine(manual1, w_9_1), 11)). asp(holds(loc_fine(book2, s_8_8), 11)).
asp(holds(loc_fine(rob1, s_9_0), 12)). asp(holds(loc_fine(manual1, s_9_0), 12)). asp(holds(loc_fine(book2, s_8_8), 12)).
asp(holds(loc_fine(rob1, s_8_0), 13)). asp(holds(loc_fine(manual1, s_8_0), 13)). asp(holds(loc_fine(book2, s_8_8), 13)).
asp(holds(loc_fine(rob1, s_8_9), 14)). asp(holds(loc_fine(manual1, s_8_9), 14)). asp(holds(loc_fine(book2, s_8_8), 14)).
asp(holds(loc_fine(rob1, s_8_8), 15)). asp(holds(loc_fine(manual1, s_8_8), 15)). asp(holds(loc_fine(book2, s_8_8), 15)).
asp(holds(loc_fine(rob1, s_8_8), 16)). asp(holds(loc_fine(manual1, s_8_8), 16)). asp(holds(loc_fine(book2, s_8_8), 16)).
asp(holds(loc_fine(rob1, s_8_8), 17)). asp(holds(loc_fine(manual1, s_8_8), 17)). asp(holds(loc_fine(book2, s_8_8), 17)).
asp(holds(loc_fine(rob1, s_8_8), 18)). asp(holds(loc_fine(manual1, s_8_8), 18)). asp(holds(loc_fine(book2, s_8_8), 18)).
asp(holds(loc_fine(rob1, s_8_8), 19)). asp(holds(loc_fine(manual1, s_8_8), 19)). asp(holds(loc_fine(book2, s_8_8), 19)).
asp(holds(loc_fine(rob1, s_8_8), 20)). asp(holds(loc_fine(manual1, s_8_8), 20)). asp(holds(loc_fine(book2, s_8_8), 20)).
asp(holds(loc_fine(rob1, s_8_8), 21)). asp(holds(loc_fine(manual1, s_8_8), 21)). asp(holds(loc_fine(book2, s_8_8), 21)).
asp(holds(loc_fine(rob1, s_9_8), 22)). asp(holds(loc_fine(manual1, s_8_8), 22)). asp(holds(loc_fine(book2, s_9_8), 22)).
asp(holds(loc_fine(rob1, s_9_9), 23)). asp(holds(loc_fine(manual1, s_8_8), 23)). asp(holds(loc_fine(book2, s_9_9), 23)).
asp(holds(loc_fine(rob1, s_0_9), 24)). asp(holds(loc_fine(manual1, s_8_8), 24)). asp(holds(loc_fine(book2, s_0_9), 24)).
asp(holds(loc_fine(rob1, o_1_9), 25)). asp(holds(loc_fine(manual1, s_8_8), 25)). asp(holds(loc_fine(book2, o_1_9), 25)).
asp(holds(loc_fine(rob1, o_2_9), 26)). asp(holds(loc_fine(manual1, s_8_8), 26)). asp(holds(loc_fine(book2, o_2_9), 26)).
asp(holds(loc_fine(rob1, o_3_9), 27)). asp(holds(loc_fine(manual1, s_8_8), 27)). asp(holds(loc_fine(book2, o_3_9), 27)).
asp(holds(loc_fine(rob1, o_3_8), 28)). asp(holds(loc_fine(manual1, s_8_8), 28)). asp(holds(loc_fine(book2, o_3_8), 28)).
asp(holds(loc_fine(rob1, o_4_8), 29)). asp(holds(loc_fine(manual1, s_8_8), 29)). asp(holds(loc_fine(book2, o_4_8), 29)).
asp(holds(loc_fine(rob1, o_5_8), 30)). asp(holds(loc_fine(manual1, s_8_8), 30)). asp(holds(loc_fine(book2, o_5_8), 30)).
asp(holds(loc_fine(rob1, o_6_8), 31)). asp(holds(loc_fine(manual1, s_8_8), 31)). asp(holds(loc_fine(book2, o_6_8), 31)).
asp(holds(loc_fine(rob1, o_6_7), 32)). asp(holds(loc_fine(manual1, s_8_8), 32)). asp(holds(loc_fine(book2, o_6_7), 32)).
asp(holds(loc_fine(rob1, o_7_7), 33)). asp(holds(loc_fine(manual1, s_8_8), 33)). asp(holds(loc_fine(book2, o_7_7), 33)).
asp(holds(loc_fine(rob1, o_8_7), 34)). asp(holds(loc_fine(manual1, s_8_8), 34)). asp(holds(loc_fine(book2, o_8_7), 34)).
asp(holds(loc_fine(rob1, o_9_7), 35)). asp(holds(loc_fine(manual1, s_8_8), 35)). asp(holds(loc_fine(book2, o_9_7), 35)).
asp(holds(loc_fine(rob1, o_9_6), 36)). asp(holds(loc_fine(manual1, s_8_8), 36)). asp(holds(loc_fine(book2, o_9_6), 36)).
asp(holds(loc_fine(rob1, o_9_5), 37)). asp(holds(loc_fine(manual1, s_8_8), 37)). asp(holds(loc_fine(book2, o_9_5), 37)).
asp(holds(loc_fine(rob1, o_9_5), 38)). asp(holds(loc_fine(manual1, s_8_8), 38)). asp(holds(loc_fine(book2, o_9_5), 38)).
asp(holds(loc_fine(rob1, o_9_5), 39)). asp(holds(loc_fine(manual1, s_8_8), 39)). asp(holds(loc_fine(book2, o_9_5), 39)).
asp(holds(loc_fine(rob1, o_9_5), 40)). asp(holds(loc_fine(manual1, s_8_8), 40)). asp(holds(loc_fine(book2, o_9_5), 40)).
