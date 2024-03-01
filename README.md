# Spatial correlation of building performances for regional resilience assessment

## Use
Run Main_i_*.m in order in Matlab

## Principle

![Regional seismic loss assessment considering spatial correlation](https://github.com/youtian95/SpatialCorBlds/blob/master/Figures/ForReadme/RegLossSim.jpg)

##  Layout

 - **3rd Party**: other dependent programs
 - **Figures**: output figures for displaying results
 - **IMSim**: simulation of intensity measure fields
 - **Opensees FEM models**: structural model, IDA results, and regional dynamic analysis
	 - EQ Records: ground motion records for IDA analysis and regional simulation
	 - lib: for opensees running
	 - MRF3: one of the structure models
		 - Results: IDA analysis
		 - Scenario Chi-Chi19990920: regional dynamic analysis
	 - ...
 - **PEER NGA Data**: PEER NGA data of ground motions, including 1994 Northridge and 1999 Chi-Chi earthquakes
 - **seismic loss assessment**: seismic loss assessment of buildings
