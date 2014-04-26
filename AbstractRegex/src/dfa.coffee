# ## Imports
# * * *
Node = node.Node
Tree = node.Tree
extend = utils.extend
# ## Token
# * * *
# Basic token for regular expression parsing
# The following types are defined
# - `/` match exactly 1 character with the metadata
# - `*` match 0 or more characters with the metadata
# - `?` match 0 or 1 characters with the metadata
# - `|` branch the current path into to directions, metadata is a list of children
# - `()` open and close an anonymous capture group
# - `{}` open and close a named capture group
class Token extends Node
	# #### constructor
	constructor: (@type, @meta, next) -> super next


# ## Path
# * * *
class Path extends Tree
	# #### constructor
	constructor: (root) ->
		super root
		@pointer = 0
		@anonStack = []
		@anonRanges = []
		@namedStack = []
		@namedRanges = {}

	# #### consumeToken
	consumeToken: ->
		@next()
		@

	# #### advancePointer
	advancePointer: ->
		@pointer++
		@

	# #### beginAnonymousCapture
	beginAnonymousCapture: ->
		@anonStack.push ["(", @pointer]
		@

	# #### endAnonymousCapture
	endAnonymousCapture: ->
		@anonRanges.push [@anonStack.pop().pop(), @pointer]
		@

	# #### beginNamedCapture
	beginNamedCapture: (name) ->
		# Trying to maintain a degree of separation between
		# [`Token`](section-2) implementation and `Path` implementation.
		# Thus, `name` is passed in as an argument and not pulled from `node`.
		@namedStack.push ["{", @pointer, name]
		@
	
	# #### endNamedCapture
	endNamedCapture: ->
		[symbol, startPointer, name] = @namedStack.pop()
		@namedRanges[name] = [startPointer, @pointer]
		@

	# #### flushAllCaptures
	# Immediately close all capture groups.
	flushAllCaptures: ->
		while @anonStack[0]?
			@endAnonymousCapture()

		while @namedStack[0]?
			@endNamedCapture()

	reset: ->
		super()
		@pointer = 0


# ## execute
# * * *
# Executes a Regular Expression search on a sequence of characters.
# A character can be any object, it is not restricted to being a one char string.
# Returns a stateful [`Path`](#section-4) object if there is a successful match, `null` otherwise.
execute = (sequence, rootToken) ->
	
	paths = [new Path new Node rootToken]

	while paths[0]?

		keep = []

		for path in paths

			if path.pointer is sequence.length

				# The current path has reached the end of a sequence.
				# It's completely matched a (sub)string of `sequence`

				if not path.node?

					# The current path has also consumed all of its tokens.
					# It's a perfect match for `sequence`. 
					# This is a successful end condition.

					# Current path
					return path

				else if path.node.type not in ["}", ")"]
					
					# We need to clean up the straggling group closures
					#
					# _TODO: Or do we? can we just automatically close them?_
					#

					# Any path nodes that aren't these kinds of closures are
					# dead-ends, because there aren't any characters left in the sequence!
					# Avoid adding them to `keep` by `continue`ing.
					continue

			if not path.node?

				# We haven't reached the end of the sequence, but this path
				# has consumed all of its [`Token`](#section-2)s

				if paths.length is 1

					# There are no other paths to consider, so the best we can hope for
					# is a partial match

					# Close all open groups.
					# 
					# _TODO: As referenced in a previous `if` block. Maybe we can export
					# this functionality and use it in both exit points._

					for [symbol, pointer, name] in path.stack
						range = [pointer, path.pointer]
						if name? 
							path.namedRanges[name] = range
						else
							path.anonRanges.push range

					return path

				else

					# There are other paths, and this one just consumed too many tokens.
					# (Perhaps, the current token is a greedy asterisk?).
					# Either way, this isn't a viable path, so we won't push it onto the `keep`
					# stack.
					continue

			switch path.type

				# ##### /
				when "/"
					# Raw match. Match one token to one character.
					if path.node.meta sequence[path.pointer]
						# Only keep the current path if there's a match
						keep.push path.consumeToken().advancePointer()

				# ##### \*
				when "*"
					# Branching match. Match zero or more characters.
					if path.node.meta sequence[path.pointer]
						# One possibility is to be greedy. Keep the same token and try to match more!
						keep.push path.copy().advancePointer()

						# Or we can be nice and go to the next token
						keep.push path.copy().consumeToken().advancePointer()

					# Zero matches. It's okay, just go to the next token.
					keep.push path.consumeToken()

				# ##### ?
				when "?"
					# Branching match. Match zero or one character.
					if path.node.meta sequence[path.pointer]
						# Unlike `*`, `?` isn't greedy. Consume the token and advance the pointer.
						keep.push path.consumeToken().advancePointer()

					else
						# No match, no worries. Next token!
						keep.push path.consumeToken()

				# ##### |
				when "|"
					# Branch/path splitting. A `|` node doesn't have a `next`. The children
					# are stored in the `meta` property.
					for child in path.node.meta
						path_ = path.copy()

						# _TODO: While it doesn't matter much in the current implementation,
						# branching creates a broken link between the current node and the root
						# node in each path. One fix would be to make [`Token`](section-2)`.next` an
						# array by default. Then, the task would merely be to prune each copy of path
						# to contain only one `node` property._
						path_.node = child

						keep.push path_

				# ##### \(
				when "("
					# start anonymous capture
					keep.push path.beginAnonymousCapture().consumeToken()

				# ##### \)
				when ")"
					# end anonymous capture
					keep.push path.endAnonymousCapture().consumeToken()

				# ##### \{
				when "{"
					# start named capture
					keep.push path.beginNamedCapture(path.node.meta).consumeToken()

				# ##### \}
				when "}"
					# end named capture
					keep.push path.endNamedCapture().consumeToken()

				else
					# _TODO: Possibly just ignore unrecognized tokens? This would allow
					# metadata such as comments to remain in the linked list._
					throw "SymbolError: Unrecognized Token Type"

		paths = keep

	# Return `null` on no match
	null

# ## Exports
# * * *
@dfa =
	Token: Token
	Path: Path
	execute: execute

if exports?
	extend exports, @dfa