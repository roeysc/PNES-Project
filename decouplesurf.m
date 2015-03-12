function bnd = decouplesurf(bnd)
    for ii = 1:length(bnd)-1
      % Despite what the instructions for surfboolean says, surfaces should
      % be ordered from inside-out!!
      [newnode, newelem] = surfboolean(bnd(ii+1).pnt,bnd(ii+1).tri,'decouple',bnd(ii).pnt,bnd(ii).tri);
      bnd(ii+1).tri = newelem(newelem(:,4)==2,1:3) - size(bnd(ii+1).pnt,1);
      bnd(ii+1).pnt = newnode(newnode(:,4)==2,1:3);
    end
end