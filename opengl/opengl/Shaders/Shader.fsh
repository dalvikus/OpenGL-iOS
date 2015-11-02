//
//  Shader.fsh
//  opengl
//
//  Created by Gwang-Ho KIM on 11/1/15.
//  Copyright (c) 2015 DN2Soft. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
