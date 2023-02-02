% function xView = octaveXViewtransform(axesHandle)
% INPUT: axesHandle (axes object)
% OUTPUT: 4 x 8 projection matrix transforming world coordinates to camera coordinates

% This function is needed because the projection matrix (x_viewtransform)
% originally a public property of the axes object, is no longer available after Octave 4.2.2
% and hence cannot be retrived by get(axesHandle, 'x_viewtransform').

% We recover this projection matrix following the procedure provided 
% in Octave 4.2.2 source code
% and translate it into native Octave.
% The source code we referenced comes from
% Ocatave-4.2.2/libinterp/corefcn/graphics.cc, Line: 5254-5454, function:
% void axes::properties::update_camera(void)

function xView = octaveXViewtransform(axesHandle)

    TOL = 1e3 * eps;

    xformVector = [zeros(3,1); 1];
    xformMatrix = eye(4);

    % aspect ratio
    pb = get(axesHandle, 'PlotBoxAspectRatio')(:);

    % initialize camera related vectors
    cupv = ceye = ccenter = xformVector;

    axis_dir = @(x) 2*strcmp(x,'normal') - 1;

    xyzd = [ axis_dir(get(axesHandle, 'xdir')); ...
        axis_dir(get(axesHandle, 'ydir')); ...
        axis_dir(get(axesHandle, 'zdir')) ];

    oxyz = [xlim()(double(xyzd(1)<0) + 1); 
        ylim()(double(xyzd(2)<0) + 1); 
        zlim()(double(xyzd(3)<0) + 1)];

    dxyz = diff([xlim; ylim; zlim],1, 2);

    % get camera target
    if strcmp( get(axesHandle, 'CameraTargetMode'), 'auto' )
        ccenter(1:3) = 0.5 * sum( [xlim; ylim; zlim], 2);
        set(axesHandle, 'CameraTarget', xform2cam(ccenter)');
    else
        ccenter = cam2xform( get(axesHandle, 'CameraTarget') )(:);
    end

    % get camera position
    if strcmp( get(axesHandle, 'CameraPositionMode'), 'auto' )
        tview = get(axesHandle, 'view');
        az = tview(1); el = tview(2);
        d = 5 * sqrt( dot_prod(pb,pb) );

        if abs( (abs(el)-90) ) < TOL
            ceye(3) = d * sign(el);
        else
            az = az * pi/180;
            el = el * pi/180;
            ceye(1:3) = [ d*cos(el)*sin(az); -d*cos(el)*cos(az); d*sin(el) ];
        end

        ceye(1:3) = ceye(1:3) .* dxyz ./ xyzd ./ pb + ccenter(1:3);
        set(axesHandle, 'CameraPosition', xform2cam(ceye)');

    else
        ceye = cam2xform( get(axesHandle, 'CameraPosition') )(:);

    end

    % set camera upvector
    if strcmp( get(axesHandle, 'CameraUpVectorMode'), 'auto' )
        tview = get(axesHandle, 'view');
        az = tview(1); el = tview(2);

        if abs( (abs(el)-90) ) < eps*1e3
            cupv(1) = -sign(el)*sin(az*pi/180)*dxyz(1)/pb(1);
            cupv(2) =  sign(el)*cos(az*pi/180)*dxyz(2)/pb(2);
        else
            cupv(3) = 1;
        end
        set(axesHandle, 'CameraUpvector', xform2cam(cupv)');

    else
        cupv = cam2xform( get(axesHandle, 'CameraUpvector') );

    end

    l = xView = xpre = xformMatrix;
    xpre = scale(xpre, pb);
    xpre = translate(xpre, [-0.5, -0.5, -0.5]');
    xpre = scale(xpre, xyzd./dxyz);
    xpre = translate(xpre, -oxyz);

    ceye = xform(ceye, xpre);
    ccenter = xform(ccenter, xpre);
    cupv = scale(cupv, pb./dxyz);
    ccenter = translate(ccenter, -ceye(1:3));
    
    F = ccenter; f = F; UP = cupv;
    f = normalize(f);
    UP = normalize(UP);
    if ( abs(dot_prod(f,UP)) > TOL )
        fa = 1 / sqrt( 1 - f(3)*f(3) );
        UP = scale(UP, [fa;fa;fa]);
    end
    s = cross_prod(f, UP);
    u = cross_prod(s, f);

    xView = scale( xView, [1,1,-1]' );
    l(1, 1:3) = s;
    l(2, 1:3) = u;
    l(3, 1:3) = -f(1:3);

    xView = xView * l;
    xView = translate(xView, -ceye(1:3));
    xView = scale(xView, pb(:));
    xView = translate(xView, -0.5*ones(3,1));

end

% ----------------------------------------------
function vout = scale(vin, x)
    assert(size(x) == [3,1]);
    if isvector(vin)
        vout = vin;
        vout(1:3) = vin(1:3) .* x(:);
    else
        vout = vin * diag([x(:); 1]);
    end
end

% ----------------------------------------------
function vout = translate(m, x)
    assert(size(x) == [3,1]);
    if isvector(m)
        vout = m;
        vout(1:3) = m(1:3) + x;
    else
        xform_translate = eye(4);
        xform_translate(:,4) = [x(:);1];
        vout = m*xform_translate;
    end
end

% ----------------------------------------------
function r = cross_prod(v1, v2)
    assert(isvector(v1) && isvector(v2))
    r = cross(v1(1:3), v2(1:3))(:);
end
function d = dot_prod(v1, v2)
    d = sum(v1(1:3).* v2(1:3));
end

% ----------------------------------------------
function vout = normalize(vin)
    assert(isvector(vin));
    vout = vin;
    vout(1:3) = vin(1:3) / sqrt(sum(vin(1:3).^2));
end

% ----------------------------------------------
function vout = xform2cam(vin)
    vout = zeros(1,3);
    vout = vin(1:3);
end
function vout = cam2xform(vin)
    vout = ones(4,1);
    vout(1:3) = vin;
end
function vout = xform(vin, m)
    vout = m * vin(:);
end

% ----------------------------------------------

