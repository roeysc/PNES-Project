

cfg = struct;
cfg.funparameter    = 'avg.pow'; %string, functional parameter that is color coded (default = 'avg.pow')
cfg.maskparameter   = []; %string, functional parameter that is used for opacity (default = [])

        load('C:\Users\Roey\Desktop\mesh\mesh_spmTemplate.mat');
        mrimesh = ft_convert_units(mrimesh,'cm');
        sourceRestOne.tri = mrimesh.tri;
ft_sourcemovie(cfg,sourceRestOne)
