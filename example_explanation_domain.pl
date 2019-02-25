
:- discontiguous asp/1.

testing_output_file('explanation_test1_output.txt').

% action_syntax(ActionName, PastTense, [List]) gives syntactic information for each action, to fit into the grammar rule
%    "[actor] [verb past tense] [object1] {to [object2]} {by [object3]} {with [object4]} {and [object5]}"
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
action_syntax(serve_extend, 'served', [actor, object4, object1, object2, object3]).
action_syntax(serve_retract, 'retracted', [actor, object1]).
action_syntax(putdown_extend, 'put down', [actor, object4, object1, object3]).
action_syntax(putdown_retract, 'raised', [actor, object1]).
action_syntax(pickup_extend, 'picked up', [actor, object4, object1, object3]).
action_syntax(pickup_retract, 'raised', [actor, object1]).

% Default
use_pov(rob1).

/*
study1, office1, workshop1, kitchen1 each comprised of four cells.
Objects: manual1, book1, book2.
Entities: rob1, p1, p2.
Fine arm position, extended/retracted.
Serve involves two fine actions: retracted->extended->retracted
Putdown involves two fine actions: retracted->extended->retracted
Pickup involves two fine actions: retracted->extended->retracted
Summary: Robot rob1 starts in w1 holding manual1, traverses to s4 to pick up book2, traverses to o2 to serve book2 to p1.

+----+----+ +----+----+
|    |    | |    |    |
| s1 | s2 | | o1 | o2 |
|    |    | |    |    |
+----+----+ +----+----+
|    |    | |    |    |
| s3 | s4 D D o3 | o4 |
|    |    | |    |    |
+----+-DD-+ +-DD-+----+

+----+-DD-+ +-DD-+----+
|    |    | |    |    |
| w1 | w2 D D k1 | k2 |
|    |    | |    |    |
+----+----+ +----+----+
|    |    | |    |    |
| w3 | w4 | | k3 | k4 |
|    |    | |    |    |
+----+----+ +----+----+
*/


% Initial ASP terms:
%
asp(coarse(hpd(move(rob1,study1),1))).
  asp(fine(hpd(move_fine(rob1,w1,w2),1))).
  asp(fine(hpd(move_fine(rob1,w2,s4),2))).
asp(coarse(hpd(putdown(rob1,manual1),3))).
  asp(fine(hpd(putdown_extend(rob1,rob1_hand,manual1,manual1_cover),3))).
  asp(fine(hpd(putdown_retract(rob1,rob1_hand),4))).
asp(coarse(hpd(pickup(rob1,book2),5))).
  asp(fine(hpd(pickup_extend(rob1,rob1_hand,book2,book2_spine),5))).
  asp(fine(hpd(pickup_retract(rob1,rob1_hand),6))).
asp(coarse(hpd(move(rob1,office1),7))).
  asp(fine(hpd(move_fine(rob1,s4,o3),7))).
  asp(fine(hpd(move_fine(rob1,o3,o4),8))).
  asp(fine(hpd(move_fine(rob1,o4,o2),9))).
asp(coarse(hpd(serve(rob1,book2,p1),10))).
  asp(fine(hpd(serve_extend(rob1,rob1_hand,book2,p1,book2_spine),10))).
  asp(fine(hpd(serve_retract(rob1,rob1_hand),11))).
link([1, 2], move(rob1,study1), 1).
link([3, 4], putdown(rob1,manual1), 3).
link([5, 6], pickup(rob1,book2), 5).
link([7, 8, 9], move(rob1,office1), 7).
link([10, 11], serve(rob1,book2,p1), 10).
plan([1, 3, 5, 7, 10]).
asp(goal(11)).
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
asp(sort_group(place_fine, [area])).
asp(sort_group(entity_fine, [robot_part, person_part])).
asp(sort_group(object_fine, [cup_fine, spine, cover, parcel_fine])).
asp(sorts(area, [s1, s2, s3, s4, o1, o2, o3, o4, k1, k2, k3, k4, w1, w2, w3, w4])).
asp(sorts(robot_part, [rob1_hand, rob1_wheel1, rob1_wheel2])).
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
asp(predicate(purpose(study1, library))).
asp(predicate(purpose(office1, office))).
asp(predicate(purpose(kitchen1, kitchen))).
asp(predicate(purpose(workshop1, workshop))).
%
asp(predicate(position(s2, northeast))).
asp(predicate(position(s1, northwest))).
asp(predicate(position(s4, entry))).
asp(predicate(position(s3, southwest))).
asp(predicate(position(o2, northeast))).
asp(predicate(position(o1, northwest))).
asp(predicate(position(o4, southeast))).
asp(predicate(position(o3, entry))).
asp(predicate(position(w2, entry))).
asp(predicate(position(w1, northwest))).
asp(predicate(position(w4, southeast))).
asp(predicate(position(w3, southwest))).
asp(predicate(position(k2, northeast))).
asp(predicate(position(k1, entry))).
asp(predicate(position(k4, southeast))).
asp(predicate(position(k3, southwest))).
asp(predicate(purpose(s1, archival))).
asp(predicate(purpose(s2, archival))).
asp(predicate(purpose(s3, archival))).
asp(predicate(purpose(s4, archival))).
asp(predicate(purpose(o1, staff))).
asp(predicate(purpose(o2, staff))).
asp(predicate(purpose(o3, staff))).
asp(predicate(purpose(o4, staff))).
asp(predicate(purpose(k1, break))).
asp(predicate(purpose(k2, break))).
asp(predicate(purpose(k3, break))).
asp(predicate(purpose(k4, break))).
asp(predicate(purpose(w1, mechanical))).
asp(predicate(purpose(w2, mechanical))).
asp(predicate(purpose(w3, mechanical))).
asp(predicate(purpose(w4, mechanical))).
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
%
asp(holds(loc(rob1, workshop1), 1)).
asp(holds(loc(rob1, workshop1), 2)).
asp(holds(loc(rob1, study1), 3)).
asp(holds(loc(rob1, study1), 4)).
asp(holds(loc(rob1, study1), 5)).
asp(holds(loc(rob1, study1), 6)).
asp(holds(loc(rob1, study1), 7)).
asp(holds(loc(rob1, office1), 8)).
asp(holds(loc(rob1, office1), 9)).
asp(holds(loc(rob1, office1), 10)).
asp(holds(loc(rob1, office1), 11)).
asp(holds(loc(rob1, office1), 12)).
asp(holds(loc_fine(rob1, w1), 1)).
asp(holds(loc_fine(rob1, w2), 2)).
asp(holds(loc_fine(rob1, s4), 3)).
asp(holds(loc_fine(rob1, s4), 4)).
asp(holds(loc_fine(rob1, s4), 5)).
asp(holds(loc_fine(rob1, s4), 6)).
asp(holds(loc_fine(rob1, s4), 7)).
asp(holds(loc_fine(rob1, o3), 8)).
asp(holds(loc_fine(rob1, o4), 9)).
asp(holds(loc_fine(rob1, o2), 10)).
asp(holds(loc_fine(rob1, o2), 11)).
asp(holds(loc_fine(rob1, o2), 12)).
%
asp(holds(loc(manual1, workshop1), 1)).
asp(holds(loc(manual1, workshop1), 2)).
asp(holds(loc(manual1, study1), 3)).
asp(holds(loc(manual1, study1), 4)).
asp(holds(loc(manual1, study1), 5)).
asp(holds(loc(manual1, study1), 6)).
asp(holds(loc(manual1, study1), 7)).
asp(holds(loc(manual1, study1), 8)).
asp(holds(loc(manual1, study1), 9)).
asp(holds(loc(manual1, study1), 10)).
asp(holds(loc(manual1, study1), 11)).
asp(holds(loc(manual1, study1), 12)).
asp(holds(loc_fine(manual1, w1), 1)).
asp(holds(loc_fine(manual1, w2), 2)).
asp(holds(loc_fine(manual1, s4), 3)).
asp(holds(loc_fine(manual1, s4), 4)).
asp(holds(loc_fine(manual1, s4), 5)).
asp(holds(loc_fine(manual1, s4), 6)).
asp(holds(loc_fine(manual1, s4), 7)).
asp(holds(loc_fine(manual1, s4), 8)).
asp(holds(loc_fine(manual1, s4), 9)).
asp(holds(loc_fine(manual1, s4), 10)).
asp(holds(loc_fine(manual1, s4), 11)).
asp(holds(loc_fine(manual1, s4), 12)).
%
% Invariants
asp(holds(loc(p1, office1), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12]).
asp(holds(loc_fine(p1, o2), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12]).
asp(holds(loc(p2, kitchen1), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12]).
asp(holds(loc_fine(p2, k3), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12]).
asp(holds(loc(book1, study1), T)) :- member(T, [1,2,3,4,5,6,7,8,9,10,11,12]).
asp(holds(loc_fine(book1, s_4_2), T)) :- member(T, [1,2,3,4,5,6,7,8,9,10,11,12]).
%
asp(holds(loc(book2, study1), 1)).
asp(holds(loc(book2, study1), 2)).
asp(holds(loc(book2, study1), 3)).
asp(holds(loc(book2, study1), 4)).
asp(holds(loc(book2, study1), 5)).
asp(holds(loc(book2, study1), 6)).
asp(holds(loc(book2, study1), 7)).
asp(holds(loc(book2, office1), 8)).
asp(holds(loc(book2, office1), 9)).
asp(holds(loc(book2, office1), 10)).
asp(holds(loc(book2, office1), 11)).
asp(holds(loc(book2, office1), 12)).
asp(holds(loc_fine(book2, s4), 1)).
asp(holds(loc_fine(book2, s4), 2)).
asp(holds(loc_fine(book2, s4), 3)).
asp(holds(loc_fine(book2, s4), 4)).
asp(holds(loc_fine(book2, s4), 5)).
asp(holds(loc_fine(book2, s4), 6)).
asp(holds(loc_fine(book2, s4), 7)).
asp(holds(loc_fine(book2, o3), 8)).
asp(holds(loc_fine(book2, o4), 9)).
asp(holds(loc_fine(book2, o2), 10)).
asp(holds(loc_fine(book2, o2), 11)).
asp(holds(loc_fine(book2, o2), 12)).
%
asp(holds(in_hand(rob1, manual1), 1)).
asp(holds(in_hand(rob1, manual1), 2)).
asp(holds(in_hand(rob1, manual1), 3)).
asp(holds(in_hand(rob1, book2), 6)).
asp(holds(in_hand(rob1, book2), 7)).
asp(holds(in_hand(rob1, book2), 8)).
asp(holds(in_hand(rob1, book2), 9)).
asp(holds(in_hand(rob1, book2), 10)).
asp(holds(in_hand(p1, book2), 11)).
asp(holds(in_hand(p1, book2), 12)).
asp(holds(in_hand_fine(rob1, rob1_hand, manual1, manual1_cover), 1)).
asp(holds(in_hand_fine(rob1, rob1_hand, manual1, manual1_cover), 2)).
asp(holds(in_hand_fine(rob1, rob1_hand, manual1, manual1_cover), 3)).
asp(holds(in_hand_fine(rob1, rob1_hand, book2, book2_spine), 6)).
asp(holds(in_hand_fine(rob1, rob1_hand, book2, book2_spine), 7)).
asp(holds(in_hand_fine(rob1, rob1_hand, book2, book2_spine), 8)).
asp(holds(in_hand_fine(rob1, rob1_hand, book2, book2_spine), 9)).
asp(holds(in_hand_fine(rob1, rob1_hand, book2, book2_spine), 10)).
asp(holds(in_hand_fine(p1, p1_hand, book2, book2_spine), 11)).
asp(holds(in_hand_fine(p1, p1_hand, book2, book2_spine), 12)).
%
asp(holds(arm_position(rob1, retracted), 1)).
asp(holds(arm_position(rob1, retracted), 2)).
asp(holds(arm_position(rob1, retracted), 3)).
asp(holds(arm_position(rob1, extended), 4)).
asp(holds(arm_position(rob1, retracted), 5)).
asp(holds(arm_position(rob1, extended), 6)).
asp(holds(arm_position(rob1, retracted), 7)).
asp(holds(arm_position(rob1, retracted), 8)).
asp(holds(arm_position(rob1, retracted), 9)).
asp(holds(arm_position(rob1, retracted), 10)).
asp(holds(arm_position(rob1, extended), 11)).
asp(holds(arm_position(rob1, retracted), 12)).
