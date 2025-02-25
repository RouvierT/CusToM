function [c,ceq] = fCL2(in1)
%FCL2
%    [C,CEQ] = FCL2(IN1)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    17-Feb-2021 14:56:10

q8 = in1(8,:);
q9 = in1(9,:);
q10 = in1(10,:);
q14 = in1(11,:);
q15 = in1(12,:);
q16 = in1(13,:);
q17 = in1(14,:);
q18 = in1(15,:);
q19 = in1(16,:);
q20 = in1(17,:);
q21 = in1(18,:);
q22 = in1(19,:);
q23 = in1(20,:);
c = zeros(0,0);
if nargout > 1
    t2 = cos(q8);
    t3 = cos(q9);
    t4 = cos(q10);
    t5 = cos(q14);
    t6 = cos(q15);
    t7 = cos(q16);
    t8 = cos(q17);
    t9 = cos(q21);
    t10 = cos(q22);
    t11 = cos(q23);
    t12 = sin(q8);
    t13 = sin(q9);
    t14 = sin(q10);
    t15 = sin(q14);
    t16 = sin(q15);
    t17 = sin(q16);
    t18 = sin(q17);
    t19 = sin(q21);
    t20 = sin(q22);
    t21 = sin(q23);
    t51 = q18+4.419444444444444e-2;
    t22 = t5.*t7;
    t23 = t4.*t12;
    t24 = t5.*t17;
    t25 = t7.*t15;
    t26 = t8.*t16;
    t27 = t12.*t14;
    t28 = t15.*t17;
    t29 = t16.*t18;
    t31 = t5.*t6.*t8;
    t32 = t6.*t7.*t8;
    t33 = t2.*t4.*t13;
    t35 = t5.*t6.*t18;
    t36 = t6.*t8.*t15;
    t37 = t6.*t7.*t18;
    t38 = t6.*t10.*t17;
    t39 = t2.*t13.*t14;
    t42 = t6.*t15.*t18;
    t43 = t6.*t17.*t20;
    t30 = t16.*t28;
    t34 = t16.*t22;
    t40 = t16.*t24;
    t41 = t16.*t25;
    t45 = -t32;
    t46 = -t33;
    t48 = -t35;
    t49 = -t36;
    t50 = -t38;
    t52 = t26+t37;
    t53 = t23+t39;
    t44 = -t30;
    t47 = -t34;
    t54 = t24+t41;
    t55 = t25+t40;
    t56 = t29+t45;
    t57 = t27+t46;
    t60 = t9.*t52;
    t62 = t19.*t52;
    t58 = t22+t44;
    t59 = t28+t47;
    t61 = t8.*t54;
    t63 = t18.*t54;
    t64 = t20.*t55;
    t65 = t9.*t56;
    t68 = t19.*t56;
    t66 = t8.*t59;
    t67 = t10.*t58;
    t69 = t18.*t59;
    t70 = t20.*t58;
    t71 = -t68;
    t73 = t42+t61;
    t74 = t49+t63;
    t80 = -t9.*(t36-t63);
    t82 = -t19.*(t36-t63);
    t86 = t19.*(t36-t63);
    t87 = t62+t65;
    t72 = -t70;
    t75 = t31+t69;
    t76 = t9.*t73;
    t77 = t19.*t73;
    t78 = t48+t66;
    t83 = -t9.*(t35-t66);
    t84 = -t19.*(t35-t66);
    t88 = t60+t71;
    t89 = t11.*t87;
    t90 = t21.*t87;
    t79 = t9.*t75;
    t81 = t19.*t75;
    t91 = t10.*t88;
    t92 = t20.*t88;
    t93 = -t90;
    t98 = t77+t80;
    t99 = t76+t86;
    t85 = -t81;
    t94 = t43+t91;
    t95 = t50+t92;
    t100 = t10.*t98;
    t101 = t20.*t98;
    t102 = t79+t84;
    t103 = t11.*t99;
    t104 = t21.*t99;
    t96 = t11.*t94;
    t97 = t21.*t94;
    t105 = t83+t85;
    t106 = t10.*t102;
    t108 = t67+t101;
    t109 = t72+t100;
    t111 = -t11.*(t70-t100);
    t112 = -t21.*(t70-t100);
    t113 = t21.*(t70-t100);
    t107 = -t106;
    t114 = t89+t97;
    t115 = t93+t96;
    t116 = t104+t111;
    t117 = t103+t113;
    t110 = t64+t107;
    ceq = [sqrt(t53.*t117+t57.*t116-t114.*(t2.*t4-t13.*t27)+t13.*(t10.*t55+t20.*t102)-(t90-t96).*(t2.*t14+t13.*t23)-t3.*t4.*(t21.*(t81+t9.*(t35-t66))+t11.*t110)+t3.*t14.*(t11.*(t81+t9.*(t35-t66))-t21.*t110)+t2.*t3.*t108+t3.*t12.*(t38-t92)+1.0)./2.0-1.0;t13.*t108+t3.*t4.*t116-t3.*t14.*t117;-t13.*(t38-t92)+t3.*t14.*t114-t3.*t4.*(t90-t96);-t53.*t114-t57.*(t90-t96)-t2.*t3.*(t38-t92);t16.*(-6.688888888888889e-2)-t26.*4.420587176470588e-2-t37.*4.420587176470588e-2-q20.*t52-t2.*t4.*2.794044444444444e-2-t3.*t12.*1.934044444444444e-2+t2.*t14.*1.301671549019608e-1+t6.*t17.*3.741e-2+t13.*t23.*1.301671549019608e-1+t13.*t27.*2.794044444444444e-2+t51.*t56+q19.*t6.*t17+2.515500000000001e-2;t22.*(-3.741e-2)-t23.*2.794044444444444e-2+t27.*1.301671549019608e-1+t30.*3.741e-2-t33.*1.301671549019608e-1+t36.*4.420587176470588e-2-t39.*2.794044444444444e-2-t63.*4.420587176470588e-2-q19.*t58+t2.*t3.*1.934044444444444e-2+t6.*t15.*(4.3e+1./3.0e+2)-t51.*t73+q20.*(t36-t63)+2.315311111111112e-2;t13.*1.934044444444444e-2-t25.*3.741e-2-t31.*4.420587176470588e-2-t40.*3.741e-2-t69.*4.420587176470588e-2-q19.*t55-q20.*t75+t3.*t4.*1.301671549019608e-1-t5.*t6.*7.58992156862745e-2+t3.*t14.*2.794044444444444e-2+t51.*(t35-t66)-3.842126725490195e-2];
end
