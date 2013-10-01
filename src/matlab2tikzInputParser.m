function parser = matlab2tikzInputParser()
%MATLAB2TIKZINPUTPARSER   Input parsing for matlab2tikz..
%   This implementation exists because Octave is lacking one.

%   Copyright (c) 2008--2013 Nico Schlömer
%   All rights reserved.
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%
%       * Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
%       * Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in
%         the documentation and/or other materials provided with the distribution
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.
% =========================================================================
  % Initialize the structure.
  parser = struct ();
  % Public Properties
  parser.Results = {};
  % Enabel/disable parameters case sensitivity.
  parser.CaseSensitive = false;
  % Enable/disable error for parameters not defined by the constructor.
  parser.KeepUnmatched = false;
  % Enable/disable passing arguments in a structure.
  parser.StructExpand = true;
  % Names of parameters defined in input parser constructor.
  parser.Parameters = {};
  % Names of parameters not defined in the constructor.
  parser.Unmatched = struct ();
  % Names of parameters using default values.
  parser.UsingDefaults = {};

  % Handles for functions that act on the object.
  parser.addRequired   = @addRequired;
  parser.addOptional   = @addOptional;
  parser.addParamValue = @addParamValue;
  parser.parse         = @parse;

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
