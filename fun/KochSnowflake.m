%% Koch snowflake
% Anthony Austin, November 2012

%%
% (Chebfun example fun/KochSnowflake.m)
% [Tags: #fun, #fractal, #ARCLENGTH, #koch, #snowflake>]

%%
% In the spirit of the upcoming holiday season, let's use Chebfun to have a
% little fun with the well-known Koch snowflake fractal.

%%
% In order to be able to use proper MATLAB functions (which we need for
% this example), we need to enclose this entire script within the body of a
% function.

function KochSnowflake()

LW = 'LineWidth'; lw = 1; FS = 'FontSize'; fs = 14;

%%
% First, we need a way to generate the points on the snowflake curve.
% Recall that the Koch snowflake is generated by starting with an
% equilateral triangle and then, at each iteration step, replacing the
% middle of each line segment with two smaller line segments that construct
% the sides of an equilateral triangle that sits on top of the path where
% the segment used to lie:

seg1 = complex([-1 1]);
seg2 = [-1 -1/3 2*1i/3 1/3 1];

subplot(2, 1, 1)
plot(seg1, LW, lw)
ylim([-0.2 0.7])
axis equal
title('Original path segment', FS, fs)

subplot(2, 1, 2)
plot(seg2, LW, lw)
ylim([-0.2 0.7])
axis equal
title('After one iteration', FS, fs)

%%
% The following function creates a column vector of all the snowflake's
% vertices after N iterations of the fractal generating step.  The vertices
% are represented by points in the complex plane.

function K = koch(N)
	% Start with the corners of an equilateral triangle.
	K = [   0 + 1i/sqrt(3)
	     -0.5 - 1i/(2*sqrt(3))
     	      0.5 - 1i/(2*sqrt(3))
                0 + 1i/sqrt(3)]; % Repeat the first point to close the path.

      	% Repeatedly split the sides of the snowflake to generate the fractal.
	for (n = 1:1:N)
		K = nextkoch(K);
	end
end

%%
% The real work of the koch() function is all contained inside the
% nextkoch() auxiliary function, which carries out the fractal iteration.
% It accepts a column vector of vertices generated by one step and returns
% a column vector of the vertices obtained after a single step of the
% iteration.

function Kn = nextkoch(K)
	N = length(K) - 1;     % Current number of unique vertices.
	M = 4*N + 1;           % Total number of vertices after next step.
	Kn = zeros(M, 1);      % New list of vertices.

	% Insert the current vertices into the new list.
	Kn(1:4:M) = K(1:end);

	for (n = 1:1:N)
		% Pick out a vertex and the next one in the sequence.
		z1 = K(n);
		z2 = K(n + 1);

		% Compute new points on the curve between these vertices.
		w1 = 2*z1/3 + 1*z2/3;
		w3 = 1*z1/3 + 2*z2/3;
		w2 = (w1 + w3)/2 + 1i*sqrt(3)*(w1 - w3)/2;

		% Insert the new vertices into the list.
		Kn(4*(n - 1) + 2) = w1;
		Kn(4*(n - 1) + 3) = w2;
		Kn(4*(n - 1) + 4) = w3;
	end
end

%%
% Finally, we develop a parametric representation of the snowflake path.  The
% following function parametrizes the path with vertices in the column vector K
% by a parameter t that ranges over [0, 1]:

function y = kochfn(K, t)
	M = length(K);

	m1 = floor((M-1)*t) + 1;
	m2 = min(m1 + 1, M);

	s = (M-1)*t + 1 - m1;
	y = K(m1).*(1 - s) + K(m2).*s;
end

%%
% Now we can play!  Let's start by creating a chebfun that represents the
% Koch snowflake after three fractal iterations.  Since the snowflake path
% is quite jagged, we will need to enable splitting:

splitting on
K = koch(3);
z = chebfun(@(t) kochfn(K, t), [0 1]);

greet1 = 0.4*scribble('Merry');
greet1x = real(greet1);
greet1y = imag(greet1);
y1min = min(greet1y);
y1max = max(greet1y);
ht1 = y1max - y1min;

greet2 = 0.4*scribble('Christmas!');
greet2x = real(greet2);
greet2y = imag(greet2);
x2min = min(greet2x);
x2max = max(greet2x);
y2min = min(greet2y);
y2max = max(greet2y);
c2 = ((x2min + x2max) + (y2min + y2max)*1i)/2;
ht2 = y2max - y2min;

hr = ht2/ht1;
greet1 = greet1*hr;
greet1x = greet1x*hr;
greet1y = greet1y*hr;
x1min = min(greet1x);
x1max = max(greet1x);
y1min = min(greet1y);
y1max = max(greet1y);
c1 = ((x1min + x1max) + (y1min + y1max)*1i)/2;

greet1 = greet1 - c1 + 0.2i;
greet2 = greet2 - c2 - 0.2i;
xmgreen = [0 0.5 0];

clf
h = fill(real(z), imag(z), [0.6 0.6 1]);
hold on;
plot(greet1, 'Color', xmgreen, LW, 2)
plot(greet2, 'Color', xmgreen, LW, 2)
hold off;
set(h, 'EdgeColor', 'r', LW, 3.0)
title('Koch Snowflake', FS, fs)
axis equal

%%
% How big is the snowflake chebfun?

length(z)
z.nfuns

%%
% We see that it needs 387 points to represent the snowflake curve, split up
% between 192 linear pieces:  one for each line segment on the curve.  Since
% two points determine a line, we would expect it to need only 2*192 = 384
% points, so it seems that the constructor has decided that a few of the
% segments need an extra point or two to resolve.

%%
% The preceding code built the snowflake curve by sampling the path and using
% Chebfun's automatic edge detection feature to insert breakpoints at the
% corners, where the path fails to be smooth.  We can build the curve more
% efficiently by determining the locations of these points ahead of time and
% passing them directly to the constructor, along with function handles that
% define the curve path in between the breakpoints:

N = length(K) - 1;
ends = 1:1:(N + 1);
paths = cell(N, 1);

for (n = 1:1:N)
	paths{n} = @(t) K(n)*(1 - (t - n)) + K(n + 1)*(t - n);
end

z = chebfun(paths, ends);

plot(z, LW, lw)
title('Koch snowflake (built a different way)', FS, fs)
axis equal

%%
% Let's try deforming the snowflake curve using a few maps:

clf

expz = exp(z);
sinz = sin(2*z);
asinz = asin(2*z);
besselz = besselj(0, z);

subplot(2, 2, 1)
plot(expz, LW, lw)
title('exp(z)', FS, fs)
axis equal

subplot(2, 2, 2)
plot(sinz, LW, lw)
title('sin(2z)', FS, fs)
axis equal

subplot(2, 2, 3)
plot(asinz, LW, lw)
title('asin(2z)', FS, fs)
axis equal

subplot(2, 2, 4)
plot(besselz, LW, lw)
title('J_0(z)', FS, fs)
axis equal

%%
% How big are the chebfuns corresponding to these new curves?  Let's look at
% the last one as an example:

length(besselz)

%%
% The image curves require quite a few more points to resolve the the original
% one.  This is expected, since the edges of the image curves are true curves
% and not just lines.

%%
% By using the map 1/z, we get a snowflake of a different variety:

clf
recipz = 1./z;
plot(recipz, LW, lw)
title('1/z', FS, fs)
axis equal

%%
% Can you explain why the map used in the next plot gives such a
% strange-looking result?

clf
pz = z.^2 + (1i/5)*z - (1+1i)/25;
plot(pz, LW, lw)
title('Image Under z^2 + (1i/5)z - (1+1i)/25', FS, fs)
axis equal

%%
% How long is the snowflake curve?

L3 = arclength(z)

%%
% This number is fairly modest, but in fact, one can show that the length
% of the curve becomes arbitrarily large as the number of iterations is
% increased. We can investigate its rate of growth by examining the lengths
% of some of the lower iterates:

K0 = koch(0);
f0 = chebfun(@(t) kochfn(K0, t), [0 1]);
L0 = arclength(f0)

K1 = koch(1);
f1 = chebfun(@(t) kochfn(K1, t), [0 1]);
L1 = arclength(f1)

K2 = koch(2);
f2 = chebfun(@(t) kochfn(K2, t), [0 1]);
L2 = arclength(f2)

%%
% In particular, consider the ratios of the lengths between the iterates:

L1/L0
L2/L1
L3/L2

%%
% We conclude that the ratio of the lengths of successive iterates is 4/3.
% (Can you see from the definition of the fractal iteration step why this
% must be the case?)  From this, we can compute the snowflake's Hausdorff
% dimension [1]:

D = log(4)/log(3)

%%
% This number tells us that that Koch snowflake behaves, in some respects,
% as an approximately "1.26-dimensional" object: a little more than just a
% line but somewhat less than a planar region.

end

%% References
%
% 1. Falconer, K. J. _The Geometry of Fractal Sets_.  Cambridge University
%    Press, 1986.


