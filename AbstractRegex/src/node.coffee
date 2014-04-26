# ## Imports
copyExtend = utils.copyExtend
extend = utils.extend

# ## Node
# Node base class
class Node

	# ### constructor
	constructor: (@next) ->

	# ### copy
	# Make a semi-shallow copy of itself
	copy: () -> 
		new_ = new @constructor
		copyExtend new_, @

# ## Tree
# Node that stores the _root_
class Tree

	# ### constructor
	constructor: (@root) -> 
		@node = @root

	# ### next
	next: ->
		@node = @node?.next
		@

	# ### end
	end: -> @node?

	# ### reset
	reset: -> @node = @root

# ### copy
# Give tree semi-shallow copy capabilities
Tree::copy = Node::copy

@node ?=
	Node: Node
	Tree: Tree

if exports?
	extend exports, @node