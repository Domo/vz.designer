class Model
	def initialize(args)
		for method_name in args.keys
			define method method_name.to_s do
				return args[method_name]
			end
		end
	end
end