
:- discontiguous asp/1.

% "[actor] [verb past tense] [object1] {to [object2]} {by [object3]} {with [object4]} {and [object5]}"

% Initial syntactic information / grammar rules:
%
action_syntax(pour, 'poured', [actor, object1, object2]).
action_syntax(mix, 'mixed', [actor, object1]).
action_syntax(scrape, 'scraped', [actor, object1, object2]).
action_syntax(preheat, 'preheated', [actor, object1, object2]).
action_syntax(pick_up, 'picked up', [actor, object1]).
action_syntax(bake, 'baked', [actor, object1, object4]).
action_syntax(reposition, 'repositioned', [actor, object2]).
%
action_syntax(grasp, 'grasped', [actor, object1]).
action_syntax(tilt, 'tilted', [actor, object1]).
action_syntax(release, 'released', [actor, object1]).
action_syntax(position_spatula_effector, 'positioned the spatula effector', [actor, object3]).
action_syntax(mixing_trajectory, 'performed a mixing trajectory', [actor, object4]).
action_syntax(wipe_spatula_effector, 'wiped the spatula effector', [actor, object4]).
action_syntax(scrape_spatula_effector, 'scraped in', [actor, object4, object2]).
action_syntax(press_down, 'pressed down', [actor, object1]).
action_syntax(set_dial, 'set', [actor, object1, object2]).
action_syntax(lift, 'lifted', [actor, object1]).
action_syntax(open_door, 'opened', [actor, object1]).
action_syntax(align, 'aligned', [actor, object1, object5]).
action_syntax(close_door, 'closed', [actor, object1]).
action_syntax(wait, 'waited for minutes equal', [actor, object2]).
action_syntax(approach, 'approached', [actor, object1]).
action_syntax(halt, 'halted at', [actor, object1]).
% Comment out for third-person reporting.
use_pov(rob1).

/*
We reconstruct and extend a state/action space and accompanying scenario from Bollini et al. (2013).
http://cs.brown.edu/people/stellex/publications/bollini12.pdf
This domain is a kitchen environment in which a robotic chef follows recipes.

"Kitchen environment consisting of two work surfaces, one for preparation and another to support a standard toaster oven
(preheated to the temperature specified in the instruction set).
... We assume that the kitchen is mise en place; ingredients are pre-measured and distributed on bowls on the table.
... Equipment includes four plastic ingredient bowls of various sizes and colors containing premeasured ingredients, a large plastic mixing bowl, and a metallic pie pan.
The items are arranged in a grid on the table, with the relative position of every item noted."


+----+----+----+----+----+----+
|    |    |    |    |    |    |
| b1 | b2 | b3 | b4 | b5 | b6 |
|    |    |    |    |    |    |
+----+----+----+----+----+----+
|    |    |    |    |    |    |
| f1 | f2 | f3 | f4 | f5 | f6 |
|    |    |    |    |    |    |
+----+----+----+----+----+----+


+----+----+----+----+----+----+
|							  |
|							  |
|			________		  |
|			| oven |		  |
|			--------		  |
|							  |
|							  |
+----+----+----+----+----+----+


#thing: {object, agent, foodstuff}
#object: {container, oven, table}
#container: {bowl, baking_tray}
#bowl: {mixing_bowl, ingredient_bowl}
#mixing_bowl: {mixbowl1}
#ingredient_bowl: {bowl1, bowl2, bowl3, bowl4, bowl5}
#baking_tray: {btray1}
#oven: {toaster_oven}
#toaster_oven: {toven1}
#table: {table1, table2}
#agent: {robot}
#robot: {rob1}
#foodstuff: {ingredient, product}
#ingredient: {cornflakes, sugar, butter, flour, cocoa}
#product: {biscuits}

#attribute_value: {number, fine_grid, color, size, status, descriptor}
#number:  1-n
#fine_grid: {front1, front2, front3, back1, back2, back3}
#color: {red, blue, yellow, metallic}
#size: {small, medium, large}
#status: {open, closed}
#descriptor: {toasting, active, north, south}

%% Predicates:
contains(#container, #foodstuff).
facing(#robot, #table).
holding(#robot, #container).
in(#baking_tray, #oven).
on(#oven, #table).
setting(#oven, #number).
is(#oven, #status).
position(#container, #table, #fine_grid).
has_color(#container, #color).
has_size(#container, #size).
type(#object, #descriptor).
arm_aligned(#robot, #thing).
spatula_effector_positioned_at(#robot, #object).

%% Actions:
pour(#robot, #ingredient_bowl, #container).
mix(#robot, #mixing_bowl).
scrape(#robot, #bowl, #baking_tray).
preheat(#robot, #oven, #number).
pick_up(#robot, #object).
bake(#robot, #baking_tray, #oven).
reposition(#robot, #table).

%% Pour involves 6 fine actions:
grasp(robot, ingredient_bowl)
lift(robot, ingredient_bowl)
align(robot, ingredient_bowl, container)
tilt(robot, ingredient_bowl)
align(robot, ingredient_bowl, table)
release(robot, ingredient_bowl)

%% Mix involves 4 fine actions:
grasp(robot, mixing_bowl)
position_spatula_effector(robot, mixing_bowl)
mixing_trajectory(robot, mixing_bowl)
wipe_spatula_effector(robot, mixing_bowl)

%% Scrape involves 7 fine actions:
grasp(robot, bowl)
lift(robot, bowl)
align(robot, bowl, baking_tray)
tilt(robot, bowl)
position_spatula_effector(robot, bowl)
scrape_spatula_effector(robot, bowl, baking_tray)
press_down(robot, baking_tray)

%% Preheat involves 3 fine actions:
grasp(robot, oven)
set_dial(robot, oven, temperature)
release(robot, oven)

%% Pick_up involves 2 fine actions:
grasp(robot, container)
lift(robot, container)

%% Bake involves up to 10 fine actions:
align(robot, baking_tray, table)
release(robot, baking_tray)
open_door(robot, oven)
grasp(robot, baking_tray)
lift(robot, baking_tray)
align(robot, baking_tray, oven)
release(robot, baking_tray)
close_door(robot, oven)
wait(robot, 20)
open_door(robot, oven)

%% Reposition involves 2 fine actions:
approach(robot, table)
halt(robot, table)

Initial state:
facing(rob1,table2).
position(bowl1, table1, back1).		contains(bowl1, sugar).			has_color(bowl1, red).			has_size(bowl1, small).
position(bowl2, table1, back2).		contains(bowl2, cornflakes).	has_color(bowl2, red).			has_size(bowl2, medium).
position(bowl3, table1, back3).		contains(bowl3, butter).		has_color(bowl3, blue).			has_size(bowl3, small).
position(bowl4, table1, front1).	contains(bowl4, flour).			has_color(bowl4, blue).			has_size(bowl4, medium).
position(bowl5, table1, front2).	contains(bowl5, cocoa).			has_color(bowl5, yellow).		has_size(bowl5, small).
position(mixbowl1, table1, front3).									has_color(mixbowl1, yellow).	has_size(mixbowl1, large).
position(btray1, table1, front3).									has_color(btray1, metallic).	has_size(btray1, medium).
on(toven1, table2).
setting(toven1, 0).
is(oven, closed).

POUR(robot, ingredient_bowl, container)
preconditions: ingredient_bowl contains 1+ ingredient
effects: contents are now in container instead of ingredient_bowl

MIX(robot, mixing_bowl)
preconditions: mixing_bowl contains 1+ ingredient

SCRAPE(robot, bowl, baking_tray)
preconditions: bowl contains 1+ ingredient
effects: contents are now in baking_tray instead of bowl

PREHEAT(robot, oven, number)
preconditions: oven does not contain something
effects: oven temperature setting is increased

PICK_UP(robot, container)
preconditions: robot not holding anything, robot facing table container is located on
effects: robot holding container
% An analogous action would remove a container from an oven on a table the robot is facing (not needed for this scenario)

BAKE(robot, baking_tray, oven)
preconditions: baking_tray contains something, oven does not contain something
effects: baking_tray now contains product instead of ingredients

Target plan is 'Afghan Biscuits recipe'. Pseudocode:
1. preheat(rob1, toven1, 350)
2. reposition(rob1, table1)
3. pour(rob1, bowl3, mixbowl1) % butter
4. mix(rob1, mixbowl1)
5. pour(rob1, bowl1, mixbowl1) % sugar
6. mix(rob1, mixbowl1)
7. pour(rob1, bowl4, mixbowl1) % flour
8. pour(rob1, bowl5, mixbowl1) % cocoa
9. pour(rob1, bowl2, mixbowl1) % cornflakes
10. mix(rob1, mixbowl1)
11. scrape(rob1, mixbowl1, btray1)
12. pick_up(rob1, btray1)
13. reposition(rob1, table2)
14. bake(rob1, btray1, toven1)

*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initial ASP terms:
%
asp(sort_group(attribute_value, [number, fine_grid, color, size, status, descriptor])).
asp(sort_group(thing, [agent, foodstuff, object])).
asp(sort_group(agent, [robot])).
asp(sort_group(foodstuff, [ingredient, product])).
asp(sort_group(object, [container, oven, table])).
asp(sort_group(container, [bowl, baking_tray])).
asp(sort_group(bowl, [mixing_bowl, ingredient_bowl])).
asp(sort_group(oven, [toaster_oven])).
asp(sorts(ingredient_bowl, [bowl1, bowl2, bowl3, bowl4, bowl5])).
asp(sorts(ingredient, [cornflakes, sugar, butter, flour, cocoa])).
asp(sorts(product, [biscuits])).
asp(sorts(mixing_bowl, [mixbowl1])).
asp(sorts(baking_tray, [btray1])).
asp(sorts(toaster_oven, [toven1])).
asp(sorts(robot, [rob1])).
asp(sorts(table, [table1, table2])).
asp(sorts(color, [red, blue, yellow, metallic])).
asp(sorts(size, [small, medium, large])).
asp(sorts(fine_grid, [front1, front2, front3, back1, back2, back3])).
asp(sorts(status, [open, closed])).
asp(sorts(descriptor, [toasting, active, north, south])).
asp(sorts(number, _)).
%

asp(coarse(hpd(preheat(rob1, toven1, 350),1))).
  asp(fine(hpd(grasp(rob1, toven1),1))).
  asp(fine(hpd(set_dial(rob1, toven1, 350),2))).
  asp(fine(hpd(release(rob1, toven1),3))).
asp(coarse(hpd(reposition(rob1, table1),4))).
  asp(fine(hpd(approach(rob1, table1),4))).
  asp(fine(hpd(halt(rob1, table1),5))).
asp(coarse(hpd(pour(rob1, bowl3, mixbowl1),6))). % butter
  asp(fine(hpd(grasp(rob1, bowl3),6))).
  asp(fine(hpd(lift(rob1, bowl3),7))).
  asp(fine(hpd(align(rob1, bowl3, mixbowl1),8))).
  asp(fine(hpd(tilt(rob1, bowl3),9))).
  asp(fine(hpd(align(rob1, bowl3, table1),10))).
  asp(fine(hpd(release(rob1, bowl3),11))).
asp(coarse(hpd(mix(rob1, mixbowl1),12))).
  asp(fine(hpd(grasp(rob1, mixbowl1),12))).
  asp(fine(hpd(position_spatula_effector(rob1, mixbowl1),13))).
  asp(fine(hpd(mixing_trajectory(rob1, mixbowl1),14))).
  asp(fine(hpd(wipe_spatula_effector(rob1, mixbowl1),15))).
asp(coarse(hpd(pour(rob1, bowl1, mixbowl1),16))). % sugar
  asp(fine(hpd(grasp(rob1, bowl1),16))).
  asp(fine(hpd(lift(rob1, bowl1),17))).
  asp(fine(hpd(align(rob1, bowl1, mixbowl1),18))).
  asp(fine(hpd(tilt(rob1, bowl1),19))).
  asp(fine(hpd(align(rob1, bowl1, table1),20))).
  asp(fine(hpd(release(rob1, bowl1),21))).
asp(coarse(hpd(mix(rob1, mixbowl1),22))).
  asp(fine(hpd(grasp(rob1, mixbowl1),22))).
  asp(fine(hpd(position_spatula_effector(rob1, mixbowl1),23))).
  asp(fine(hpd(mixing_trajectory(rob1, mixbowl1),24))).
  asp(fine(hpd(wipe_spatula_effector(rob1, mixbowl1),25))).
asp(coarse(hpd(pour(rob1, bowl4, mixbowl1),26))). % flour
  asp(fine(hpd(grasp(rob1, bowl4),26))).
  asp(fine(hpd(lift(rob1, bowl4),27))).
  asp(fine(hpd(align(rob1, bowl4, mixbowl1),28))).
  asp(fine(hpd(tilt(rob1, bowl4),29))).
  asp(fine(hpd(align(rob1, bowl4, table1),30))).
  asp(fine(hpd(release(rob1, bowl4),31))).
asp(coarse(hpd(pour(rob1, bowl5, mixbowl1),32))). % cocoa
  asp(fine(hpd(grasp(rob1, bowl5),32))).
  asp(fine(hpd(lift(rob1, bowl5),33))).
  asp(fine(hpd(align(rob1, bowl5, mixbowl1),34))).
  asp(fine(hpd(tilt(rob1, bowl5),35))).
  asp(fine(hpd(align(rob1, bowl5, table1),36))).
  asp(fine(hpd(release(rob1, bowl5),37))).
asp(coarse(hpd(pour(rob1, bowl2, mixbowl1),38))). % cornflakes
  asp(fine(hpd(grasp(rob1, bowl2),38))).
  asp(fine(hpd(lift(rob1, bowl2),39))).
  asp(fine(hpd(align(rob1, bowl2, mixbowl1),40))).
  asp(fine(hpd(tilt(rob1, bowl2),41))).
  asp(fine(hpd(align(rob1, bowl2, table1),42))).
  asp(fine(hpd(release(rob1, bowl2),43))).
asp(coarse(hpd(mix(rob1, mixbowl1),44))).
  asp(fine(hpd(grasp(rob1, mixbowl1),44))).
  asp(fine(hpd(position_spatula_effector(rob1, mixbowl1),45))).
  asp(fine(hpd(mixing_trajectory(rob1, mixbowl1),46))).
  asp(fine(hpd(wipe_spatula_effector(rob1, mixbowl1),47))).
asp(coarse(hpd(scrape(rob1, mixbowl1, btray1),48))).
  asp(fine(hpd(grasp(rob1, mixbowl1),48))).
  asp(fine(hpd(lift(rob1, mixbowl1),49))).
  asp(fine(hpd(align(rob1, mixbowl1, btray1),50))).
  asp(fine(hpd(tilt(rob1, mixbowl1),51))).
  asp(fine(hpd(position_spatula_effector(rob1, mixbowl1),52))).
  asp(fine(hpd(scrape_spatula_effector(rob1, mixbowl1, btray1),53))).
  asp(fine(hpd(press_down(rob1, btray1),54))).
asp(coarse(hpd(pick_up(rob1, btray1),55))).
  asp(fine(hpd(grasp(rob1, btray1),55))).
  asp(fine(hpd(lift(rob1, btray1),56))).
asp(coarse(hpd(reposition(rob1, table2),57))).
  asp(fine(hpd(approach(rob1, table2),57))).
  asp(fine(hpd(halt(rob1, table2),58))).
asp(coarse(hpd(bake(rob1, btray1, toven1),59))).
  asp(fine(hpd(align(rob1, btray1, table2),59))).
  asp(fine(hpd(release(rob1, btray1),60))).
  asp(fine(hpd(open_door(rob1, toven1),61))).
  asp(fine(hpd(grasp(rob1, btray1),62))).
  asp(fine(hpd(lift(rob1, btray1),63))).
  asp(fine(hpd(align(rob1, btray1, toven1),64))).
  asp(fine(hpd(release(rob1, btray1),65))).
  asp(fine(hpd(close_door(rob1, toven1),66))).
  asp(fine(hpd(wait(rob1, 20),67))).
  asp(fine(hpd(open_door(rob1, toven1),68))).

% Record of plan and goal
asp(goal(68)).
plan([1, 4, 6, 12, 16, 22, 26, 32, 38, 44, 48, 55, 57, 59]).
link([1,2,3], preheat(rob1, toven1, 350), 1).
link([4,5], reposition(rob1, table1), 4).
link([6,7,8,9,10,11], pour(rob1, bowl3, mixbowl1), 6).
link([12,13,14,15], mix(rob1, mixbowl1), 12).
link([16,17,18,19,20,21], pour(rob1, bowl1, mixbowl1), 16).
link([22,23,24,25], mix(rob1, mixbowl1), 22).
link([26,27,28,29,30,31], pour(rob1, bowl4, mixbowl1), 26).
link([32,33,34,35,36,37], pour(rob1, bowl5, mixbowl1), 32).
link([38,39,40,41,42,43], pour(rob1, bowl2, mixbowl1), 38).
link([44,45,46,47], mix(rob1, mixbowl1), 44).
link([48,49,50,51,52,53,54], scrape(rob1, mixbowl1, btray1), 48).
link([55,56], pick_up(rob1, btray1), 55).
link([57,58], reposition(rob1, table2), 57).
link([59,60,61,62,63,64,65,66,67,68], bake(rob1, btray1, toven1), 59).
asp_goal_string("goal(I) :- holds(contains(btray1,biscuits),I), holds(is(toven1,open),I).").

% Perceived attribute-values
asp(predicate(has_size(bowl1, small))).
asp(predicate(has_size(bowl2, medium))).
asp(predicate(has_size(bowl3, small))).
asp(predicate(has_size(bowl4, medium))).
asp(predicate(has_size(bowl5, small))).
asp(predicate(has_size(mixbowl1, large))).
asp(predicate(has_size(btray1, medium))).
asp(predicate(has_color(bowl1, red))).
asp(predicate(has_color(bowl2, red))).
asp(predicate(has_color(bowl3, blue))).
asp(predicate(has_color(bowl4, blue))).
asp(predicate(has_color(bowl5, yellow))).
asp(predicate(has_color(mixbowl1, yellow))).
asp(predicate(has_color(btray1, metallic))).
asp(predicate(type(toven1, toasting))).
asp(predicate(type(rob1, active))).
asp(predicate(type(table1, north))).
asp(predicate(type(table2, south))).

% Record of initial state + history of observations
asp(holds(facing(rob1,table2), X)) :- member(X,[1,2,3,4]).
asp(holds(position(bowl1, table1, back1), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(contains(bowl1, sugar), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]).
asp(holds(position(bowl2, table1, back2), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(contains(bowl2, cornflakes), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41]).
asp(holds(position(bowl3, table1, back3), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(contains(bowl3, butter), X)) :- member(X,[1,2,3,4,5,6,7,8,9]).
asp(holds(position(bowl4, table1, front1), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(contains(bowl4, flour), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29]).
asp(holds(position(bowl5, table1, front2), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(contains(bowl5, cocoa), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35]).
asp(holds(position(mixbowl1, table1, front3), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(position(btray1, table1, front3), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58]).
asp(holds(on(toven1, table2), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
asp(holds(is(toven1, closed), X)) :- member(X,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61]).
asp(holds(setting(toven1, 0), X)) :- member(X,[1,2]).
asp(holds(arm_aligned(rob1, rob1), 1)).
%

%%%%%%coarse(hpd(preheat(rob1, toven1, 350),1)).
%fine(hpd(grasp(rob1, toven1),1)).
asp(holds(arm_aligned(rob1, toven1), X)) :- member(X,[2,3]).
%fine(hpd(set_dial(rob1, toven1, 350),2)).
asp(holds(setting(toven1, 350), X)) :- member(X,[3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69]).
%fine(hpd(release(rob1, toven1),3)).
asp(holds(arm_aligned(rob1, rob1), X)) :- member(X,[4,5,6]).
%%%%%%coarse(hpd(reposition(rob1, table1),4)).
%fine(hpd(approach(rob1, table1),4)).
asp(not_holds(facing(rob1,table2), 5)).
%fine(hpd(halt(rob1, table1),5)).
asp(holds(facing(rob1,table1), X)) :- member(X,[6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57]).
%%%%%%coarse(hpd(pour(rob1, bowl3, mixbowl1),6)). % butter
%fine(hpd(grasp(rob1, bowl3),6)).
asp(holds(arm_aligned(rob1, bowl3), X)) :- member(X,[7,8]).
%fine(hpd(lift(rob1, bowl3),7)).
asp(holds(holding(rob1, bowl3), X)) :- member(X,[8,9,10,11]).
%fine(hpd(align(rob1, bowl3, mixbowl1),8)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[9,10]).
%fine(hpd(tilt(rob1, bowl3),9)).
asp(holds(contains(mixbowl1, butter), X)) :- member(X,[10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]).
%fine(hpd(align(rob1, bowl3, table1),10)).
asp(holds(arm_aligned(rob1, table1), X)) :- member(X,[11,12]).
%fine(hpd(release(rob1, bowl3),11)).

%%%%%%coarse(hpd(mix(rob1, mixbowl1),12)).
%fine(hpd(grasp(rob1, mixbowl1),12)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[13,14,15,16]).
%fine(hpd(position_spatula_effector(rob1, mixbowl1),13)).
asp(holds(spatula_effector_positioned_at(rob1, mixbowl1), X)) :- member(X,[14,15]).
%fine(hpd(mixing_trajectory(rob1, mixbowl1),14)).

%fine(hpd(wipe_spatula_effector(rob1, mixbowl1),15)).

%%%%%%coarse(hpd(pour(rob1, bowl1, mixbowl1),16)). % sugar
%fine(hpd(grasp(rob1, bowl1),16)).
asp(holds(arm_aligned(rob1, bowl1), X)) :- member(X,[17,18]).
%fine(hpd(lift(rob1, bowl1),17)).
asp(holds(holding(rob1, bowl1), X)) :- member(X,[18,19,20,21]).
%fine(hpd(align(rob1, bowl1, mixbowl1),18)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[19,20]).
%fine(hpd(tilt(rob1, bowl1),19)).
asp(holds(contains(mixbowl1, sugar), X)) :- member(X,[20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]).
%fine(hpd(align(rob1, bowl1, table1),20)).
asp(holds(arm_aligned(rob1, table1), X)) :- member(X,[21,22]).
%fine(hpd(release(rob1, bowl1),21)).

%%%%%%coarse(hpd(mix(rob1, mixbowl1),22)).
%fine(hpd(grasp(rob1, mixbowl1),22)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[23,24,25,26]).
%fine(hpd(position_spatula_effector(rob1, mixbowl1),23)).
asp(holds(spatula_effector_positioned_at(rob1, mixbowl1), X)) :- member(X,[24,25]).
%fine(hpd(mixing_trajectory(rob1, mixbowl1),24)).

%fine(hpd(wipe_spatula_effector(rob1, mixbowl1),25)).

%%%%%%coarse(hpd(pour(rob1, bowl4, mixbowl1),26)). % flour
%fine(hpd(grasp(rob1, bowl4),26)).
asp(holds(arm_aligned(rob1, bowl4), X)) :- member(X,[27,28]).
%fine(hpd(lift(rob1, bowl4),27)).
asp(holds(holding(rob1, bowl4), X)) :- member(X,[28,29,30,31]).
%fine(hpd(align(rob1, bowl4, mixbowl1),28)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[29,30]).
%fine(hpd(tilt(rob1, bowl4),29)).
asp(holds(contains(mixbowl1, flour), X)) :- member(X,[30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]).
%fine(hpd(align(rob1, bowl4, table1),30)).
asp(holds(arm_aligned(rob1, table1), X)) :- member(X,[31,32]).
%fine(hpd(release(rob1, bowl4),31)).

%%%%%%coarse(hpd(pour(rob1, bowl5, mixbowl1),32)). % cocoa
%fine(hpd(grasp(rob1, bowl5),32)).
asp(holds(arm_aligned(rob1, bowl5), X)) :- member(X,[33,34]).
%fine(hpd(lift(rob1, bowl5),33)).
asp(holds(holding(rob1, bowl5), X)) :- member(X,[34,35,36,37]).
%fine(hpd(align(rob1, bowl5, mixbowl1),34)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[35,36]).
%fine(hpd(tilt(rob1, bowl5),35)).
asp(holds(contains(mixbowl1, cocoa), X)) :- member(X,[36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53]).
%fine(hpd(align(rob1, bowl5, table1),36)).
asp(holds(arm_aligned(rob1, table1), X)) :- member(X,[37,38]).
%fine(hpd(release(rob1, bowl5),37)).

%%%%%%coarse(hpd(pour(rob1, bowl2, mixbowl1),38)). % cornflakes
%fine(hpd(grasp(rob1, bowl2),38)).
asp(holds(arm_aligned(rob1, bowl2), X)) :- member(X,[39,40]).
%fine(hpd(lift(rob1, bowl2),39)).
asp(holds(holding(rob1, bowl2), X)) :- member(X,[40,41,42,43]).
%fine(hpd(align(rob1, bowl2, mixbowl1),40)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[41,42]).
%fine(hpd(tilt(rob1, bowl2),41)).
asp(holds(contains(mixbowl1, cornflakes), X)) :- member(X,[42,43,44,45,46,47,48,49,50,51,52,53]).
%fine(hpd(align(rob1, bowl2, table1),42)).
asp(holds(arm_aligned(rob1, table1), X)) :- member(X,[43,44]).
%fine(hpd(release(rob1, bowl2),43)).

%%%%%%coarse(hpd(mix(rob1, mixbowl1),44)).
%fine(hpd(grasp(rob1, mixbowl1),44)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[45,46,47,48]).
%fine(hpd(position_spatula_effector(rob1, mixbowl1),45)).
asp(holds(spatula_effector_positioned_at(rob1, mixbowl1), X)) :- member(X,[46,47]).
%fine(hpd(mixing_trajectory(rob1, mixbowl1),46)).

%fine(hpd(wipe_spatula_effector(rob1, mixbowl1),47)).

%%%%%%coarse(hpd(scrape(rob1, mixbowl1, btray1),48)).
%fine(hpd(grasp(rob1, mixbowl1),48)).
asp(holds(arm_aligned(rob1, mixbowl1), X)) :- member(X,[49,50]).
%fine(hpd(lift(rob1, mixbowl1),49)).
asp(holds(holding(rob1, mixbowl1), X)) :- member(X,[50,51,52,53]).
%fine(hpd(align(rob1, mixbowl1, btray1),50)).
asp(holds(arm_aligned(rob1, btray1), X)) :- member(X,[51,52,53,54]).
%fine(hpd(tilt(rob1, mixbowl1),51)).
asp(holds(contains(btray1, cornflakes), X)) :-	member(X,[52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67]).
asp(holds(contains(btray1, sugar), X)) :-		member(X,[52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67]).
asp(holds(contains(btray1, flour), X)) :-		member(X,[52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67]).
asp(holds(contains(btray1, cocoa), X)) :-		member(X,[52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67]).
asp(holds(contains(btray1, butter), X)) :-		member(X,[52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67]).
%fine(hpd(position_spatula_effector(rob1, mixbowl1),52)).
asp(holds(spatula_effector_positioned_at(rob1, mixbowl1), X)) :- member(X,[52,53]).
%fine(hpd(scrape_spatula_effector(rob1, mixbowl1, btray1),53)).
% Note the overlapping 'contains' until scraped

%fine(hpd(press_down(rob1, btray1),54)).
asp(holds(arm_aligned(rob1, table1), X)) :- member(X,[55]).
%%%%%%coarse(hpd(pick_up(rob1, btray1),55)).
%fine(hpd(grasp(rob1, btray1),55)).
asp(holds(arm_aligned(rob1, btray1), X)) :- member(X,[56,57,58,59]).
%fine(hpd(lift(rob1, btray1),56)).
asp(holds(holding(rob1, btray1), X)) :- member(X,[57,58,59,60]).
%%%%%%coarse(hpd(reposition(rob1, table2),57)).
%fine(hpd(approach(rob1, table2),57)).
asp(not_holds(facing(rob1,table1), 58)).
%fine(hpd(halt(rob1, table2),58)).
asp(holds(facing(rob1,table2), X)) :- member(X,[59,60,61,62,63,64,65,66,67,68,69]).
asp(not_holds(position(btray1, table1, front3), 59)).
asp(holds(position(btray1, table2, front2), X)) :- member(X,[59,60,61,62,63,64,65,66,67,68,69]).
%%%%%%coarse(hpd(bake(rob1, btray1, toven1),59)).
%fine(hpd(align(rob1, btray1, table2),59)).
asp(holds(arm_aligned(rob1, table2), X)) :- member(X,[60,61]).
%fine(hpd(release(rob1, btray1),60)).

%fine(hpd(open_door(rob1, toven1),61)).
asp(holds(is(toven1, closed), X)) :- member(X,[62,63,64,65,66,67,68]).
asp(holds(arm_aligned(rob1, toven1), X)) :- member(X,[62]).
%fine(hpd(grasp(rob1, btray1),62)).
asp(holds(arm_aligned(rob1, btray1), X)) :- member(X,[63,64]).
%fine(hpd(lift(rob1, btray1),63)).
asp(holds(holding(rob1, btray1), X)) :- member(X,[64,65]).
%fine(hpd(align(rob1, btray1, toven1),64)).
asp(holds(arm_aligned(rob1, toven1), X)) :- member(X,[65,66,67,68,69]).
%fine(hpd(release(rob1, btray1),65)).
asp(holds(in(btray1, toven1), X)) :- member(X,[66,67,68,69]).
%fine(hpd(close_door(rob1, toven1),66)).
asp(holds(is(toven1, closed), X)) :- member(X,[67,68]).
%fine(hpd(wait(rob1, 20),67)).
asp(holds(contains(btray1, biscuits), X)) :- member(X,[68,69]).
%fine(hpd(open_door(rob1, toven1),68)).
asp(holds(is(toven1, open), X)) :- member(X,[69]).

% Unneeded:
% asp(not_holds(A, I))

test :-
	protocol('explanation_test2_output.txt'),
	begin_test.

begin_test :-
	member(Val1, [coarse, moderate, fine]),
	member(Val2, [1, 2, 3, 4]),
	member(Val3, [low, medium, high]),
		set_axis(representation_granularity, Val1), set_axis(communication_specificity, Val2), set_axis(complexity_detail, Val3),
		prettyprint('representation_granularity: '), prettyprintln(Val1), prettyprint('communication_specificity: '), prettyprintln(Val2), prettyprint('complexity_detail: '), prettyprintln(Val3),
		initialise_for_reset, generate_explanation, prettyprintln('\n***************\n'),
	fail.
begin_test :-
	noprotocol.

