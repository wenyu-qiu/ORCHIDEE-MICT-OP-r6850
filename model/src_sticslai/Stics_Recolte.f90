!-----------------------------------------------------------------------
! modif le 27/06/01
! NB le 01/05
! d�temination de la date de r�colte
! calcul de la date de r�colte
! plusieurs crit�res pour la r�colte
! 1- la maturit� physiologique (P_codrecolte = 1)
! 2- la teneur en eau          (P_codrecolte = 2)
! 3- la teneur en sucre        (P_codrecolte = 3)
! 4- la teneur en prot�ine     (P_codrecolte = 4)
! 5- la teneur en huile        (P_codrecolte = 5)
!-----------------------------------------------------------------------
! addressing the harvest 


 subroutine recolte(n,ndrp,gslen, drylen, lai,        & ! IN
                    nmat, nrec,              & ! INOUT
                    stmatrec,group)     ! OUT
                    
 USE Stics
 USE constantes
 !USE Messages

implicit none

! DECLARATION

! 0.1 INPUT
  integer, intent(IN)    :: n  
  integer, intent(IN)    :: ndrp  
  integer, intent(IN)    :: gslen 
  

  real,    intent(IN)    :: lai  !> // PARAMETER // minimal sugar rate at harvest // g sucre g-1 MF // PARTEC // 1 
  

  !integer, intent(IN)    :: P_codrecolte  !> // PARAMETER // harvest mode : all the plant (1) or just the fruits (2) // code 1/2 // PARTEC // 0 
  !integer, intent(IN)    :: nmat  
  !integer, intent(IN)    :: P_variete  !> // PARAMETER // variety number in the technical file // SD // PARTEC // 1 
  !integer, intent(IN)    :: P_nbcueille  !> // PARAMETER // number of fruit harvestings // code 1/2 // PARTEC // 0 
  !real,    intent(IN)    :: h2orec   !> // OUTPUT // Water content of harvested organs // %
  !real,    intent(IN)    :: P_sucrerec  !> // PARAMETER // minimal sugar rate at harvest // g sucre g-1 MF // PARTEC // 1 
  !real,    intent(IN)    :: P_CNgrainrec  !> // PARAMETER // minimal grain nitrogen content for harvest  // 0-1 // PARTEC // 1 
  !real,    intent(IN)    :: P_huilerec  !> // PARAMETER // minimal oil content allowed for harvest // g huile g-1 MF // PARTEC // 1 
  !real,    intent(IN)    :: sucre   !> // OUTPUT // Sugar content of fresh harvested organs // % (of fresh weight)
  !real,    intent(IN)    :: huile   !> // OUTPUT // Oil content of fresh harvested organs // % (of fresh weight)
  !real,    intent(IN)    :: teaugrain  
  !real,    intent(IN)    :: P_h2ofrvert  !> // PARAMETER // water content of fruits before the beginning of hydrous evolution (DEBDESHYD) // g water g-1 MF // PARPLT // 1 
  !integer, intent(IN)    :: P_codeaumin  !> // PARAMETER // harvest as a function of grain/fruit water content // code 1/2 // PARTEC // 0 
  !real,    intent(IN)    :: P_h2ograinmin  !> // PARAMETER // minimal water content allowed at harvest // g eau g-1 MF // PARTEC // 1 
  !real,    intent(IN)    :: P_deshydbase  !> // PARAMETER // phenological rate of evolution of fruit water content (>0 or <0) // g water.g MF-1.degree C-1 // PARPLT // 1
  !real,    intent(IN)    :: somcourdrp  
  !real,    intent(IN)    :: P_stdrpmat  !> // PARAMETER // Sum of development units between the stages DRP and MAT // degree.days // PARPLT // 1 
  !real,    intent(IN)    :: P_h2ograinmax  !> // PARAMETER // maximal water content allowed at harvest // g water g-1 MF // PARTEC // 1 
  !real,    intent(IN)    :: CNgrain   !> // OUTPUT // Nitrogen concentration of grains  // %
  !integer, intent(IN)    :: P_cadencerec  !> // PARAMETER // number of days between two harvests // day // PARTEC // 1 

! 0.2 INOUT
  
  integer, intent(INOUT)    :: nrec  
  integer, intent(INOUT)    :: drylen 
  integer, intent(INOUT)    :: nmat  

  !integer, intent(INOUT) :: jdepuisrec  
  !real,    intent(INOUT) :: pdsfruit   !> // OUTPUT // Weight of fruits in box 3 // g m-2
  !real,    intent(INOUT) :: nfruit   !> // OUTPUT // Number of fruits in box 5 // nb fruits
  !integer, intent(INOUT) :: nbrecolte  

! 0.3 OUT

  real,    intent(OUT)   :: stmatrec
  real,    intent(OUT)   :: group  

  !integer, intent(OUT)   :: nrecint  
  !real,    intent(OUT)   :: rdtint  
  !real,    intent(OUT)   :: teauint  
  !real,    intent(OUT)   :: nbfrint  


! 0.4 LOCAL VARIABLES 
  !real :: huiledecis  !>  
  !real :: sucredecis  !>  
  !real :: teaudecis  


    !: NB - le 27/08 - pas de passage avant ndrp
    !: first, we check the growing season length, whether or not exceed the threshold, maxgs = 300.    
    
!    print *, 'in recolte, the lai is', lai
    if ( gslen < P_maxgs ) then
       if (ndrp == 0 .or. n == ndrp) return
       
       if ( lai > 0.) then ! when grain filling  starting and lai > 0
          ! the first option, based on the physiological maturation
          ! at first, we used this option, because we do not consider the nitrogen, water, sugar processes in the grain. 
          if (P_codrecolte == 1) then
            ! NB - le 08/05/02 - ajout du test nrec
!            print *, 'in recolte, the drylen is ', drylen
            if (drylen < matrec) then  ! drying process start only since mature
               nrec = 0
            else 
               nrec = n
               stmatrec = 0.
               group = P_variete
            endif
          endif
          if (P_codrecolte == 2) then
            ! NB - le 08/05/02 - ajout du test nrec
            if (drylen < matrec) then
               nrec = 0
            else
               nrec = n
               stmatrec = 0.
               group = P_variete
            endif
          endif
       else  ! ndrp != 0 and lai <= 0, that mean there is no lai aboveground, vegetation should stop here 
          if (nmat == 0) then
             nmat = n
          else
             ;
          endif
              
          if (drylen <= 0) then
             drylen = drylen + 1
          else
             drylen = drylen
          endif
          if (drylen < matrec) then
             nrec = 0
          else 
             nrec = n
             stmatrec = 0.
             group = P_variete
          endif
!          print *,'in recolte, do we do here with lai <=0'
!          print *, 'in recolte, the drylen is', drylen
       endif
    else ! when reaching the maxgs, we forced stop the crop growth
       nmat = n
       nrec = n
       stmatrec = 0.
       group = P_variete
    endif


    !!: on r�colte lorsque la teneur en eau atteint un seuil
    !!- ajout d'un test dans condition (teaugrain /= P_h2ofrvert)
    !!- Nb - 28/09:
    !!- Teneur en eau,huile,sucre diff�rentes si une ou plusieurs r�coltes


    !!: P_nbcueille = 1
    !if (P_nbcueille == 1) then

    !  teaudecis = h2orec
    !  sucredecis = sucre
    !  huiledecis = huile

    !  if (P_codrecolte == 2) then
    !    if (nmat > 0 .or. teaudecis /= P_h2ofrvert) then
    !      if (P_codeaumin == 1 .and. teaudecis >= P_h2ograinmin .and. nrec == 0) then
    !        if (P_deshydbase >= 0.) then
    !          call EnvoyerMsgHistorique(401)
    !          stop
    !        endif
    !        nrec = n
    !        stmatrec = somcourdrp - P_stdrpmat
    !        group = P_variete
    !      endif
    !      if (P_codeaumin == 2 .and. teaudecis <= P_h2ograinmax .and. nrec == 0) then
    !        if (P_deshydbase <= 0.) then
    !          call EnvoyerMsgHistorique(402)
    !          stop
    !        endif
    !        nrec = n
    !        stmatrec = somcourdrp - P_stdrpmat
    !        group = P_variete
    !      endif
    !    endif
    !  endif

    !  ! on r�colte lorsque la teneur en sucre atteint un seuil
    !  if (P_codrecolte == 3) then
    !    if (nmat > 0 .or. teaudecis /= P_h2ofrvert) then
    !      if (sucredecis >= P_sucrerec .and. nrec == 0) then
    !        nrec = n
    !        stmatrec = somcourdrp - P_stdrpmat
    !        group = P_variete
    !      endif
    !    endif
    !  endif

    !  ! on r�colte lorsque la teneur en azote atteint un seuil
    !  if (P_codrecolte == 4) then
    !    if (nmat > 0) then
    !      if (CNgrain/100. >= P_CNgrainrec .and. nrec == 0) then
    !        nrec = n
    !        stmatrec = somcourdrp - P_stdrpmat
    !        group = P_variete
    !      endif
    !    endif
    !  endif

    !  ! on r�colte lorsque la teneur en huile atteint un seuil
    !  if (P_codrecolte == 5) then
    !    if (nmat > 0 .or. teaudecis /= P_h2ofrvert)then
    !      if (huiledecis >= P_huilerec .and. nrec == 0) then
    !        nrec = n
    !        stmatrec = somcourdrp - P_stdrpmat
    !        group = P_variete
    !      endif
    !    endif
    !  endif

    !endif ! fin P_nbcueille = 1


    !!: P_nbcueille  =  2
    !! -- if (P_nbcueille == 2.and.nrec > 0) then
    !if (P_nbcueille == 2) then

    !  teaudecis = teaugrain
    !  !--pas utilis�-- sucredecis = sucreder
    !  !--pas utilis�-- huiledecis = huileder

    !  jdepuisrec = jdepuisrec+1
    !  if ((n == nrec .or. jdepuisrec >= P_cadencerec) .and. pdsfruit > 0.) then
    !    nrecint = n
! dr!  22/12/2010 on pass� le tableau entier de rdint
    !    rdtint = pdsfruit
!   !     rdtint(1,nbrecolte) = pdsfruit
!   !        write(*,*)'***** dans stics_recolte',rdtint,pdsfruit
    !    nbfrint = nfruit
    !    teauint = teaudecis
! dr!  22/12/2010 on pass� le tableau entier de rdint
    !    pdsfruit  =  pdsfruit - rdtint
    !    nfruit  =  nfruit - nbfrint

    !    ! NB - le 08/05/02 - r�affectation de nrec ( = n)
    !    nrec = nrecint
    !    nbrecolte = nbrecolte + 1
    !    jdepuisrec = 0
!   !     write(*,*)'**fin recolte',nbrecolte,pdsfruit
    !  endif
    !endif




    !!: NB - le 02/07/02
    !!- domi et marie - 10/10/03
    !!- deplac� au debut de develop car dans le cas de P_codeperenne = 1 et P_codcueille = 1 on ne passe plus
    !!- dans recolte � partir de n = nrec
    !!- voir avec Nadine si on le vire ici
!-- !   if (P_codeperenne == 1) then
!-- !     if (P_codcueille == 1) then
!-- !       if (n == nrec+1) then
!-- !         masec = 0.0
!-- !         zrac = 0.0
!-- !         mafrais(:) = 0.0
!-- !         pdsfruitfrais(:) = 0.0
    !      ! domi - 22/10/03
!-- !         hauteur(:) = 0.
    !      ! PB - 03/05/2004 - remise � z�ro des variables de fixation
!-- !         demande(:)  =  0.
    !      ! DR 13/01/06 remise � zero sinon mafrais ne revient pas nul
!-- !         mafraisfeuille(:) = 0.
!-- !         mafraistige(:) = 0.
!-- !         mafraisres(:) = 0.
!-- !         mafraisrec(:) = 0.
!-- !       endif
!-- !     endif
!-- !   endif

! --!     if (P_nbcueille == 1.and.n == nrec) then
! --!       do 50 i = 1,P_nboite
! --!         pdsfruit(i) = 0.0
! --!         nfruit(ens,i) = 0.0
! --!50     continue
! --!     endif

return
end subroutine recolte
