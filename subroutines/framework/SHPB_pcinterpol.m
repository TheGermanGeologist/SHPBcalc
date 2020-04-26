function [ status ] = SHPB_pcinterpol( newnu,pcdatapath,newname )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

try
    % load original nu values
    load(pcdatapath,'nu')
    load(pcdatapath,'nu0')

    % check if input nu value is new
    if sum(nu == newnu) ~= 0
        status = 2;
        return
    else
    end

    % determine closest values to newnu
    % first closest, difference to all existing original values
    diff = abs(nu0 - newnu);
    [d1,pos1] = min(diff);
    value1 = nu0(pos1);
    diff(pos1) = 1000;          % set difference of closest value artificially high
    [d2,pos2] = min(diff);
    value2 = nu0(pos2);

    % interpolate values
    load(pcdatapath,'PCdata')
    data1 = PCdata(:,pos1);
    data2 = PCdata(:,pos2);
    coeff1 = abs(value1 - newnu);
    coeff2 = abs(value2 - newnu);
    sumco = coeff1 + coeff2;
    datanew = data1 * (coeff2 / sumco) + data2 * (coeff1 / sumco);

    % save new values
    load(pcdatapath,'N')
    load(pcdatapath,'PCinfo')
    load(pcdatapath,'PCinfoString')
    N = N +1;
    nu(N) = newnu;
    nustring = ['nu = ',num2str(newnu),' '];
    PCinfo(N,:) = {N,nustring,'interpolated',newname};
    infostring = [num2str(N),' - nu = ',num2str(newnu),' - interpolated - ', newname];
    PCinfoString(N,:) = {infostring};
    PCdata(:,N) = datanew;
    save(pcdatapath,'nu','PCinfo','PCinfoString','PCdata','N','-append')

    status = 1;
catch
    status = 0;
end



end
