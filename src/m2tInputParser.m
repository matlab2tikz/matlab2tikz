function parser = m2tInputParser()
%MATLAB2TIKZINPUTPARSER   Input parsing for matlab2tikz.
%   This implementation exists because Octave is lacking one.

  % Initialize the structure.
  parser = struct ();
  % Public Properties
  parser.Results = {};
  % Enabel/disable parameters case sensitivity.
  parser.CaseSensitive = false;
  % Keep parameters not defined by the constructor.
  parser.KeepUnmatched = false;
  % Enable/disable warning for parameters not defined by the constructor.
  parser.WarnUnmatched = true;
  % Enable/disable passing arguments in a structure.
  parser.StructExpand = true;
  % Names of parameters defined in input parser constructor.
  parser.Parameters = {};
  % Names of parameters not defined in the constructor.
  parser.Unmatched = struct ();
  % Names of parameters using default values.
  parser.UsingDefaults = {};
  % Names of deprecated parameters and their alternatives
  parser.DeprecatedParameters = struct();

  % Handles for functions that act on the object.
  parser.addRequired    = @addRequired;
  parser.addOptional    = @addOptional;
  parser.addParamValue  = @addParamValue;
  parser.deprecateParam = @deprecateParam;
  parser.parse          = @parse;

  % Initialize the parser plan
  parser.plan = {};
end
% =========================================================================
function p = parser_plan (q, arg_type, name, default, validator)
  p = q;
  plan = p.plan;
  if (isempty (plan))
    plan = struct ();
    n = 1;
  else
    n = numel (plan) + 1;
  end
  plan(n).type      = arg_type;
  plan(n).name      = name;
  plan(n).default   = default;
  plan(n).validator = validator;
  p.plan = plan;
end
% =========================================================================
function p = addRequired (p, name, validator)
  p = parser_plan (p, 'required', name, [], validator);
end
% =========================================================================
function p = addOptional (p, name, default, validator)
  p = parser_plan (p, 'optional', name, default, validator);
end
% =========================================================================
function p = addParamValue (p, name, default, validator)
  p = parser_plan (p, 'paramvalue', name, default, validator);
end
% =========================================================================
function p = deprecateParam (p, name, alternatives)
  if isempty(alternatives)
      alternatives = {};
  elseif ischar(alternatives)
      alternatives = {alternatives}; % make cellstr
  elseif ~iscellstr(alternatives)
      error('m2tInputParser:BadAlternatives',...
            'Alternatives for a deprecated parameter must be a char or cellstr');
  end
  p.DeprecatedParameters.(name) = alternatives;
end
% =========================================================================
function p = parse (p, varargin)
  plan = p.plan;
  results = p.Results;
  using_defaults = {};
  if (p.CaseSensitive)
    name_cmp = @strcmp;
  else
    name_cmp = @strcmpi;
  end
  if (p.StructExpand)
    k = find (cellfun (@isstruct, varargin));
    for m = numel(k):-1:1
      n = k(m);
      s = varargin{n};
      c = [fieldnames(s).'; struct2cell(s).'];
      c = c(:).';
      if (n > 1 && n < numel (varargin))
        varargin = horzcat (varargin(1:n-1), c, varargin(n+1:end));
      elseif (numel (varargin) == 1)
        varargin = c;
      elseif (n == 1);
        varargin = horzcat (c, varargin(n+1:end));
      else % n == numel (varargin)
        varargin = horzcat (varargin(1:n-1), c);
      end
    end
  end
  if (isempty (results))
    results = struct ();
  end
  type = {plan.type};
  n = find( strcmp( type, 'paramvalue' ) );
  m = setdiff (1:numel( plan ), n );
  plan = plan ([n,m]);
  for n = 1 : numel (plan)
    found = false;
    results.(plan(n).name) = plan(n).default;
    if (~ isempty (varargin))
      switch plan(n).type
      case 'required'
        found = true;
        if (strcmpi (varargin{1}, plan(n).name))
          varargin(1) = [];
        end
        value = varargin{1};
        varargin(1) = [];
      case 'optional'
        m = find (cellfun (@ischar, varargin));
        k = find (name_cmp (plan(n).name, varargin(m)));
        if (isempty (k) && validate_arg (plan(n).validator, varargin{1}))
          found = true;
          value = varargin{1};
          varargin(1) = [];
        elseif (~ isempty (k))
          m = m(k);
          found = true;
          value = varargin{max(m)+1};
          varargin(union(m,m+1)) = [];
        end
      case 'paramvalue'
        m = find( cellfun (@ischar, varargin) );
        k = find (name_cmp (plan(n).name, varargin(m)));
        if (~ isempty (k))
          found = true;
          m = m(k);
          value = varargin{max(m)+1};
          varargin(union(m,m+1)) = [];
        end
      otherwise
        error( sprintf ('%s:parse', mfilename), ...
               'parse (%s): Invalid argument type.', mfilename ...
             )
      end
    end
    if (found)
      if (validate_arg (plan(n).validator, value))
        results.(plan(n).name) = value;
      else
        error( sprintf ('%s:invalidinput', mfilename), ...
               '%s: Input argument ''%s'' has invalid value.\n', mfilename, plan(n).name ...
             );
      end
      p.Parameters = union (p.Parameters, {plan(n).name});
    elseif (strcmp (plan(n).type, 'required'))
      error( sprintf ('%s:missinginput', mfilename), ...
             '%s: input ''%s'' is missing.\n', mfilename, plan(n).name ...
           );
    else
      using_defaults = union (using_defaults, {plan(n).name});
    end
  end

  if ~isempty(varargin)
    % Include properties that do not match specified properties
      for n = 1:2:numel(varargin)
        if ischar(varargin{n})
          if p.KeepUnmatched
            results.(varargin{n}) = varargin{n+1};
          end
          if p.WarnUnmatched
            warning(sprintf('%s:unmatchedArgument',mfilename), ...
                    'Ignoring unknown argument "%s"', varargin{n});
          end
          p.Unmatched.(varargin{n}) = varargin{n+1};
        else
          error (sprintf ('%s:invalidinput', mfilename), ...
                 '%s: invalid input', mfilename)
        end
      end
  end

  % Store the results of the parsing
  p.Results = results;
  p.UsingDefaults = using_defaults;

  warnForDeprecatedParameters(p);
end
% =========================================================================
function result = validate_arg (validator, arg)
  try
    result = validator (arg);
  catch %#ok
    result = false;
  end
end
% =========================================================================
function warnForDeprecatedParameters(p)
  usedDeprecatedParameters = intersect(p.Parameters, fieldnames(p.DeprecatedParameters));

  for iParam = 1:numel(usedDeprecatedParameters)
      oldParameter = usedDeprecatedParameters{iParam};
      alternatives = p.DeprecatedParameters.(oldParameter);

      switch numel(alternatives)
          case 0
              replacements = '';
          case 1
              replacements = ['''' alternatives{1} ''''];
          otherwise
              replacements = deblank(sprintf('''%s'' and ',alternatives{:}));
              replacements = regexprep(replacements,' and$','');
      end
      if ~isempty(replacements)
          replacements = sprintf('From now on, please use %s to control the output.\n',replacements);
      end

      message = ['\n===============================================================================\n', ...
                  'You are using the deprecated parameter ''%s''.\n', ...
                  '%s', ...
                  '==============================================================================='];
      warning('matlab2tikz:deprecatedParameter', ...
                message, oldParameter, replacements);

  end
end
