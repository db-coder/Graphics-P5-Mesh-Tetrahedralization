// finding the circumcenter of 3 points

pt circumCenter(pt A, pt B, pt C)
{
  pt M = P(A, 0.5, V(A, B));
  vec N = cross(V(A, B), V(A, C));
  vec V0 = U(cross(N, V(A, B)));
  pt H = P(A, 0.5, V(A, C));
  vec AM = V(A, M);
  vec AH = V(A, H);
  float s = (dot(AH,AH) - dot(AM, AH))/(dot(V0, AH));
  pt center = P(M, s, V0);
  return center;
}

boolean isInCircle(pt A, pt center, pt point)
{
  if(d(point,center) <= d(A,center))
    return true;
  else
    return false;
}

void addTube(pt A, pt B, int num)
{
  boolean flag = false;
  if(num == 0)
  {
    for(int i = 0; i < Ptubes.nv - 1; i+=2)
    {
      if((A.x == Ptubes.G[i].x) && (A.y == Ptubes.G[i].y) && (A.z == Ptubes.G[i].z) && (B.x == Ptubes.G[i+1].x) && (B.y == Ptubes.G[i+1].y) && (B.z == Ptubes.G[i+1].z))
      {
        flag = true;
        break;
      }
    }
    if(!flag)
    {
      Ptubes.addPt(A);
      Ptubes.addPt(B);
    }
  }
  else if(num == 1)
  {
    for(int i = 0; i < Qtubes.nv - 1; i+=2)
    {
      if((A.x == Qtubes.G[i].x) && (A.y == Qtubes.G[i].y) && (A.z == Qtubes.G[i].z) && (B.x == Qtubes.G[i+1].x) && (B.y == Qtubes.G[i+1].y) && (B.z == Qtubes.G[i+1].z))
      {
        flag = true;
        break;
      }
    }
    if(!flag)
    {
      Qtubes.addPt(A);
      Qtubes.addPt(B);
    }
  }
  else if(num == 2)
  {
    for(int i = 0; i < QPtubes.nv - 1; i+=2)
    {
      if((A.x == QPtubes.G[i].x) && (A.y == QPtubes.G[i].y) && (A.z == QPtubes.G[i].z) && (B.x == QPtubes.G[i+1].x) && (B.y == QPtubes.G[i+1].y) && (B.z == QPtubes.G[i+1].z))
      {
        flag = true;
        break;
      }
    }
    if(!flag)
    {
      QPtubes.addPt(A);
      QPtubes.addPt(B);
    }
  }
  else if(num == 3)
  {
    for(int i = 0; i < EdgeTubes.nv - 1; i+=2)
    {
      if((A.x == EdgeTubes.G[i].x) && (A.y == EdgeTubes.G[i].y) && (A.z == EdgeTubes.G[i].z) && (B.x == EdgeTubes.G[i+1].x) && (B.y == EdgeTubes.G[i+1].y) && (B.z == EdgeTubes.G[i+1].z))
      {
        flag = true;
        break;
      }
    }
    if(!flag)
    {
      EdgeTubes.addPt(A);
      EdgeTubes.addPt(B);
    }
  }
}



void addEdge(pt A, pt B, int num)
{
  boolean flag = false;
  if(num == 0)
  {
    for(int i = 0; i < Pedges.nv - 1; i+=2)
    {
      if((A.x == Pedges.G[i].x) && (A.y == Pedges.G[i].y) && (A.z == Pedges.G[i].z) && (B.x == Pedges.G[i+1].x) && (B.y == Pedges.G[i+1].y) && (B.z == Pedges.G[i+1].z))
      {
        flag = true;
        Pedges.deletePt(i);
        Pedges.deletePt(i);
        break;
      }
    }
    if(!flag)
    {
      Pedges.addPt(A);
      Pedges.addPt(B);
    }
  }
  else if(num == 1)
  {
    for(int i = 0; i < Qedges.nv - 1; i+=2)
    {
      if((A.x == Qedges.G[i].x) && (A.y == Qedges.G[i].y) && (A.z == Qedges.G[i].z) && (B.x == Qedges.G[i+1].x) && (B.y == Qedges.G[i+1].y) && (B.z == Qedges.G[i+1].z))
      {
        flag = true;
        Qedges.deletePt(i);
        Qedges.deletePt(i);
        break;
      }
    }
    if(!flag)
    {
      Qedges.addPt(A);
      Qedges.addPt(B);
    }
  }
}

// finding the circumcenter of 4 points

pt circumCenter(pt A, pt B, pt C, pt D)
{
  pt center;
  pt P = circumCenter(B,C,D);
  pt P0 = circumCenter(A,B,C);
  float s = dot(V(P,P0),V(C,A))/(dot(U(cross(V(C,D),V(C,B))),V(C,A)));
  center = P(P,s,U(cross(V(C,D),V(C,B))));
  return center;
}

// finding minimum bulge point in ceiling

pt findBulge(pt A, pt B, pt C, int num)
{
  int index=0;
  pt minPt = P(0,0);
  if(num == 1)
  {
    pt D = Q.G[0];
    pt quadCenter = circumCenter(D,A,B,C);
    pt triCenter = circumCenter(A,B,C);
    float bulge = d(triCenter,quadCenter) + d(D,quadCenter);
    float min = bulge;
    minPt = D;
    for(int n = 1; n < Q.nv; n++)
    {
      D = Q.G[n];
      quadCenter = circumCenter(D,A,B,C);
      triCenter = circumCenter(A,B,C);
      bulge = d(triCenter,quadCenter) + d(D,quadCenter);
      if(min > bulge)
      {
        float radius = d(quadCenter,A); 
        boolean empty = true;
        //for (int k = 0; k < Q.nv; k++)
        //{
        //  if (d(quadCenter,Q.G[k])<radius && k!=n)
        //  {
        //    //another point is in the sphere!
        //    empty = false;
        //    break;
        //  }
        //}
        //for (int k = 0; k < P.nv; k++)
        //{
        //  if (d(quadCenter,P.G[k])<radius && notEqual(P.G[k],A) && notEqual(P.G[k],B) && notEqual(P.G[k],C))
        //  {
        //    //another point is in the sphere!
        //    empty = false;
        //    break;
        //  }
        //}
        if(empty)
        {
          min = bulge;
          minPt = D;
          index = n;
        }
      }
    }
  }
  else
  {
    pt D = P.G[0];
    pt quadCenter = circumCenter(D,A,B,C);
    pt triCenter = circumCenter(A,B,C);
    float bulge = d(triCenter,quadCenter) + d(D,quadCenter);
    float min = bulge;
    minPt = D;
    for(int n = 1; n < P.nv; n++)
    {
      D = P.G[n];
      quadCenter = circumCenter(D,A,B,C);
      triCenter = circumCenter(A,B,C);
      bulge = d(triCenter,quadCenter) + d(D,quadCenter);
      if(min > bulge)
      {
        float radius = d(quadCenter,A); 
        boolean empty = true;
        //for (int k = 0; k < P.nv; k++)
        //{
        //  if (d(quadCenter,P.G[k])<radius && k!=n)
        //  {
        //    //another point is in the sphere!
        //    empty = false;
        //    break;
        //  }
        //}
        //for (int k = 0; k < Q.nv; k++)
        //{
        //  if (d(quadCenter,Q.G[k])<radius && notEqual(Q.G[k],A) && notEqual(Q.G[k],B) && notEqual(Q.G[k],C))
        //  {
        //    //another point is in the sphere!
        //    empty = false;
        //    break;
        //  }
        //}
        if(empty)
        {
          min = bulge;
          minPt = D;
          index = n;
        }
      }
    }
  }
  return minPt;
}

pts findBulge(pt A, pt B, int num)
{
  pts minPt = new pts();
  if(num == 1)
  {
    pt C = Qedges.G[0];
    pt D = Qedges.G[1];
    pt quadCenter = circumCenter(D,C,A,B);
    pt triCenter = circumCenter(A,B,C);
    float bulge = d(triCenter,quadCenter) + d(D,quadCenter);
    float min = bulge;
    minPt.G[0] = C;
    minPt.G[1] = D;
    for(int n = 1; n < Qedges.nv-1; n+=2)
    {
      C = Qedges.G[n];
      D = Qedges.G[n+1];
      quadCenter = circumCenter(D,C,A,B);
      triCenter = circumCenter(A,B,C);
      bulge = d(triCenter,quadCenter) + d(D,quadCenter);
      if(min > bulge)
      {
        min = bulge;
        minPt.G[0] = C;
        minPt.G[1] = D;
      }
    }
  }
  else
  {
    pt C = Pedges.G[0];
    pt D = Pedges.G[1];
    pt quadCenter = circumCenter(D,C,A,B);
    pt triCenter = circumCenter(A,B,C);
    float bulge = d(triCenter,quadCenter) + d(D,quadCenter);
    float min = bulge;
    minPt.G[0] = C;
    minPt.G[1] = D;
    for(int n = 1; n < Pedges.nv-1; n+=2)
    {
      C = Pedges.G[n];
      D = Pedges.G[n+1];
      quadCenter = circumCenter(D,C,A,B);
      triCenter = circumCenter(A,B,C);
      bulge = d(triCenter,quadCenter) + d(D,quadCenter);
      if(min > bulge)
      {
        min = bulge;
        minPt.G[0] = C;
        minPt.G[1] = D;
      }
    }
  }
  return minPt;
}