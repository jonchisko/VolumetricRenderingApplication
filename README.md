# VolumetricRenderingApplication
Application for volumetric rendering of volumetric medical data (such as CTI or MRI scan). Built in Unity for Microsoft HoloLens 2.

Offers loading of the nrrd data set, pre-processing (done on the gpu with compute shaders), visualization via MS HoloLens 1, shader and object manipulation and last but not least,
transfer function (1d, 2d) editor - editing, saving, loading.

User can also use voice commands to set the values.

## Important notice
Due to implementation of special data structures to accelerate the visualization (reconstruction of a smaller bounding box volume), currently the main scene is not working 
properly (because it uses this accelerated structure, which was never properly incorporated in the old project)
