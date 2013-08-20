#[Checkers](http://en.wikipedia.org/wiki/Checkers)

Uses the `colored` gem:

```
gem install colored
```

A move consists of either a "shift" (a move of one diagonal) or a sequence of jumps. Non-kings can only move towards the opposing side of the board, whether shifting or jumping. Kings can mix it up, and can even alternate between jumping different directions, if given the opportunity.

Here's a sample set of moves to demonstrate its mechanics:

23,32

56,47

27,36

67,56

16,27

50,41

05,16

41,23,05

03,14

56,45

21,30

61,50

10,21

65,56

01,10

05,23,01


