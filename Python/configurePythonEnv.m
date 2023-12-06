function configurePythonEnv()
    % Make sure the Python environment is correctly set. This allows to call
    % Python function withing MATLAB. It is recommended to use this as the
    % first function call in any script that uses it. This is because to
    % ensure the utils are up to date the utils module needs to be reloaded
    % and this process causes all variables to be deleted.

    pe = pyenv;

%     setenv('path',['C:\Users\omar_\Anaconda3\Library\bin;', getenv('path')]);
    setenv('path',['C:\Users\omar_\anaconda3\envs\py38\Library\bin;', getenv('path')]);

    if strcmp(pe.Status, "NotLoaded")
        pyExec = 'C:\Users\omar_\anaconda3\envs\py38\python.exe';
        pyenv('Version', pyExec)
    end

   python_folder = [pwd '\Python'];
    if count(py.sys.path, python_folder) == 0
        insert(py.sys.path,int32(0),python_folder);
    end

    % Make sure the module is up to date
    clear classes
    mod = py.importlib.import_module('sequitur_utils');
    py.importlib.reload(mod);

end