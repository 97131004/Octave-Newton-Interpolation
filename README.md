# Octave Newton Interpolation

Script to perform a Newton Interpolation for a number of points in 2D space in GNU Octave.

## Technical requirements

- GNU Octave 4.2.1
- GNU Octave Package 'gnuplot' (Octave CLI: ```pkg install -forge gnuplot```)
- GNU Octave Package 'plot' (Octave CLI: ```pkg install -forge plot```)

## Usage

To run the script in Octave CLI, use: ``` newtoninterpolation ```

## Requirements for correct execution

- Input function must be a 2D function
- Input function must use ```x``` as control variable
- Input matrix must only have points where every x-value (abscissa) is assigned to exactly one y-value (ordinate)
- Input matrix does not include identical points

## Input parameters

1. Source/compare function (with quotes) as String, e.g.: ```"sqrt(x-1)"```
2. Points matrix m as Matrix, e.g.: ```[1,0;2,1;5,2;10,3]```
3. Additional test value for error calculation (x-coordinate around which the function will later be plotted) as Integer/Float, e.g.: ```8```

## Output

- Iteration steps with all calculated values from the tree structure (```delta^i y / delta^i x```)
- All coefficients ```Ai```
- Interpolated function ```f2```
- Absolute and relative error by comparing test values from interpolated and source function
- Plotting interpolated and source functions, test values and calculated errors

## Navigation controls for the plot window (if displayed via gnuplot)

- Mouse wheel = Shift y-axis
- Shift + mouse wheel = Shift x-axis
- Control + mouse wheel = Zoom in/out
- Right mouse button = Draw enlargement rectangle
- Middle mouse button = Set point (shows its coordinates)

## License
MIT