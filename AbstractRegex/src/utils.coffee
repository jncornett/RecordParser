# ## type
# Utility type checker. 
# Normalizes type checking
#
#     coffee> type a.number
#     'Number'
#     coffee> type a.string
#     'String'
#     coffee> type a.regexp
#     'RegExp'
#     coffee> type a.array
#     'Array'
#     coffee> type a.object
#     'Object'
#     coffee> type a.function
#     'Function'
#

type = (object) -> object?.constructor?.name or String object

# ## extend
# Copies the properties of `sources` into `target`, then returns `target`.

extend = (target, sources...) ->
	for source in sources
		for own key of source 
			target[key] = source[key]

	target

# ## copyExtend
# For a "somewhat" deep copy of an object.
# It will slice Arrays and extend objects that are immediate children
# of the source(s).

copyExtend = (target, sources...) ->
	for source in sources
		for own key, value of source
			target[key] = switch type value
				when "Array"
					value[..]
				when "Object"
					extend {}, value
				else
					value
	target

# ## Exports

# ### In-package
@utils =
	type: type
	extend: extend
	copyExtend: copyExtend

# ### Jasmin spec
if exports? 
	extend exports, @utils
